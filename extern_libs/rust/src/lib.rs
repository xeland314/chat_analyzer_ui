use chrono::NaiveDateTime;
use lazy_static::lazy_static;
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
mod sentiment;

// Estructuras de datos que coinciden con los modelos de Dart
#[derive(Serialize, Deserialize, Debug)]
pub struct ParsedMessage {
    author: String,
    content: String,
    timestamp: i64, // Unix timestamp en milisegundos
    #[serde(default)] // Si el sentiment falla, por defecto es 0.0 (Neutral)
    sentiment_score: f32,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ParsedParticipant {
    name: String,
    messages: Vec<ParsedMessage>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ParsedChat {
    participants: Vec<ParsedParticipant>,
}

// Regex compilados una sola vez (thread-safe)
lazy_static! {
    static ref LINE_PATTERN: Regex =
        Regex::new(r"^(\d{1,2}/\d{1,2}/\d{2,4}, \d{1,2}:\d{2}) - ([^:]+): (.+)").unwrap();
    static ref SYSTEM_PATTERN: Regex = Regex::new(
          r"los mensajes y llamadas están cifrados|\
          <Multimedia omitido>|\
          cambió su número de teléfono|\
          creó el grupo|\
          Messages and calls are end-to-end encrypted|\
          <Media omitted>|\
          changed their phone number|\
          created group" // O "created this group"
    )
    .unwrap();
    static ref YEAR_4_DIGITS: Regex = Regex::new(r"/\d{4},").unwrap();
}

// Función principal de parseo (sin análisis de sentimiento)
pub fn parse_whatsapp_chat(content: &str) -> ParsedChat {
    let mut participants: HashMap<String, Vec<ParsedMessage>> = HashMap::new();

    let lines: Vec<&str> = content.lines().collect();
    let mut current_author: Option<String> = None;
    let mut current_datetime: Option<i64> = None;
    let mut message_buffer = String::with_capacity(512); // Pre-allocate

    // Closure para guardar mensaje
    let mut save_message = |author: &str, datetime: i64, content: String| {
        let sentiment_score = sentiment::get_sentiment_score(&content);
        let message = ParsedMessage {
            author: author.to_string(),
            content,
            timestamp: datetime,
            sentiment_score,
        };

        participants
            .entry(author.to_string())
            .or_insert_with(Vec::new)
            .push(message);
    };

    for line in lines {
        // Filtro rápido antes de regex
        if line.len() > 20 && line.contains(" - ") && line.contains(": ") {
            if let Some(captures) = LINE_PATTERN.captures(line) {
                // Guardar mensaje anterior
                if let (Some(author), Some(datetime)) = (&current_author, current_datetime) {
                    if !message_buffer.is_empty() {
                        let content = std::mem::take(&mut message_buffer);
                        save_message(author, datetime, content);
                        message_buffer = String::with_capacity(512);
                    }
                }

                // Nuevo mensaje
                let datetime_str = &captures[1];
                let author = &captures[2];
                let content = &captures[3];

                // Parseo de fecha optimizado
                if let Some(timestamp) = parse_datetime(datetime_str) {
                    current_author = Some(author.to_string());
                    current_datetime = Some(timestamp);
                    message_buffer.push_str(content);
                } else {
                    // Error de parseo, tratar como continuación
                    if !message_buffer.is_empty() {
                        message_buffer.push('\n');
                        message_buffer.push_str(line);
                    }
                }
                continue;
            }
        }

        // Mensaje de sistema
        if SYSTEM_PATTERN.is_match(line) {
            continue;
        }

        // Continuación multilínea
        if !message_buffer.is_empty() {
            message_buffer.push('\n');
            message_buffer.push_str(line);
        }
    }

    // Guardar último mensaje
    if let (Some(author), Some(datetime)) = (current_author, current_datetime) {
        if !message_buffer.is_empty() {
            save_message(&author, datetime, message_buffer);
        }
    }

    // Convertir HashMap a estructura final
    let participants_list: Vec<ParsedParticipant> = participants
        .into_iter()
        .map(|(name, messages)| ParsedParticipant { name, messages })
        .collect();

    ParsedChat {
        participants: participants_list,
    }
}

// Parseo optimizado de fecha/hora
fn parse_datetime(datetime_str: &str) -> Option<i64> {
    // Detectar formato rápido
    let format = if YEAR_4_DIGITS.is_match(datetime_str) {
        "%d/%m/%Y, %H:%M"
    } else {
        "%d/%m/%y, %H:%M"
    };

    NaiveDateTime::parse_from_str(datetime_str, format)
        .ok()
        .map(|dt| dt.and_utc().timestamp_millis())
}

// ============================================================================
// FFI Interface para Dart
// ============================================================================

/// Parse WhatsApp chat y retorna JSON
/// IMPORTANTE: El caller debe liberar la memoria con free_string()
#[unsafe(no_mangle)]
pub extern "C" fn parse_whatsapp_chat_ffi(content: *const c_char) -> *mut c_char {
    // Safety check
    if content.is_null() {
        return std::ptr::null_mut();
    }

    // Convertir C string a Rust string
    let c_str = unsafe { CStr::from_ptr(content) };
    let content_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    // Parsear
    let parsed = parse_whatsapp_chat(content_str);

    // Serializar a JSON
    let json = match serde_json::to_string(&parsed) {
        Ok(j) => j,
        Err(_) => return std::ptr::null_mut(),
    };

    // Convertir a C string
    match CString::new(json) {
        Ok(c_string) => c_string.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Liberar memoria de string retornado por parse_whatsapp_chat_ffi
#[unsafe(no_mangle)]
pub extern "C" fn free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_simple_chat() {
        let content = "1/1/22, 10:30 - Alice: Hola\n\
                      1/1/22, 10:31 - Bob: Hola Alice\n\
                      1/1/22, 10:32 - Alice: ¿Cómo estás?";

        let result = parse_whatsapp_chat(content);
        assert_eq!(result.participants.len(), 2);
    }

    #[test]
    fn test_multiline_message() {
        let content = "1/1/22, 10:30 - Alice: Este es un mensaje\n\
                      que continúa en la siguiente línea\n\
                      y otra más\n\
                      1/1/22, 10:31 - Bob: Respuesta";

        let result = parse_whatsapp_chat(content);
        let alice = result
            .participants
            .iter()
            .find(|p| p.name == "Alice")
            .unwrap();

        assert!(alice.messages[0].content.contains("continúa"));
    }
}
