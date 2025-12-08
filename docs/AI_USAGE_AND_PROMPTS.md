AI usage guide — Structured exports + sample prompts
===============================================

This document explains how to use the app's structured exports (JSON/YAML/TOON/CSV) to work with an LLM or other analysis tools without sending full raw chats. It includes sample export snippets, recommended prompt templates, privacy notes, and a short glossary for non-technical users.

Nota: este documento es bilingüe (English / Español).

---

1) Why structured exports
-------------------------
- Structured exports (JSON/YAML/TOON/CSV) let you share only the summarized/needed data with an LLM or other tools. This saves tokens and preserves privacy.
- Recommended: use the JSON/YAML/TOON export containing `participants`, `messages_by_hour`, and a small `summary` (top words, emoji counts, sentiment aggregates).

2) Recommended fields to export
--------------------------------
Include a compact summary rather than full message text when possible. Example minimal structure:

```json
{
  "period": { "start": "2024-01-01T00:00:00Z", "end": "2024-12-07T23:59:59Z", "hour_reference": "UTC" },
  "total_messages": 1543,
  "participants": [
    { "name": "Alice", "messageCount": 892, "multimediaCount": 45, "peak_hour": 14, "messages_by_hour": [12,23,34,...], "top_words": [["proyecto",87],["reunión",65]] },
    { "name": "Bob", "messageCount": 651, "multimediaCount": 32, "peak_hour": 9, "messages_by_hour": [...], "top_words": [["sí",44],["ok",31]] }
  ],
  "summary": {
    "top_words": [["proyecto",120],["reunión",90]],
    "top_emojis": [["😂",212],["❤️",145]],
    "sentiment": { "positive": 580, "negative": 120, "neutral": 843 }
  }
}
```

3) TOON / compact formats
-------------------------
- If you use TOON, prefer encoding only the `summary` + `participants` sections (not full messages). That keeps payload small.
- Example TOON snippet (very short):

```
chat_analysis:
  period:
    start: 2024-01-01T00:00:00Z
    end: 2024-12-07T23:59:59Z
  total_messages: 1543
  participants:
    - name: Alice
      messageCount: 892
      peak_hour: 14
      messages_by_hour: [12,23,34,...]
  summary:
    top_words: [[proyecto,120],[reunión,90]]
```

4) Prompt templates (save tokens, be explicit)
---------------------------------------------
- Always include: the objective, the exact output format you want, and a short field glossary.

Example prompt (analysis / insights):

```
Objective: Provide a short executive summary (3–4 sentences) describing the group's activity, main topics, and any recommended actions.
Input: The following JSON with fields: participants (name, messageCount, peak_hour), summary (top_words, top_emojis, sentiment).
Output: Plain text summary, 3-4 bullets with "Action:" if any.

JSON:
<paste compact JSON here>
```

Example prompt (generate discussion questions):
```
Objective: Generate 5 discussion questions to address common topics from the chat summary.
Input: JSON summary (top_words, sentiment).
Output: A numbered list of 5 questions.

JSON:
<compact JSON here>
```

5) Privacy & best practices
---------------------------
- Do NOT send full message bodies unless absolutely necessary. Prefer `top_words` and small excerpts.
- Consider anonymizing names before sending: replace names with `User A`, `User B` or use hashed IDs.
- Keep `hour_reference` (UTC/local) in the payload so the LLM interprets peak-hour correctly.
- Remove sensitive tokens (phone numbers, emails, unique IDs) from exported fields.

6) Anonymization quick recipe
-----------------------------
- Replace each participant name with `User 1`, `User 2`, etc., and keep a local mapping file if you need to re-identify later (store mapping locally only).
- Example pseudocode: build map name -> `User N` and apply to `participants` and `messages` (if exported).

7) Field glossary (short)
-------------------------
- `messageCount`: total messages sent by participant.
- `messages_by_hour`: integer array with 24 values, index = hour (0..23).
- `peak_hour`: integer hour index with highest messages.
- `top_words`: small list of frequent tokens (word, count).
- `sentiment`: aggregate counts or average sentiment.

8) Where to put this in the repo
--------------------------------
- This file: `docs/AI_USAGE_AND_PROMPTS.md`
- Suggestion: update this file after relevant changes to the export schema.

---

Español — Guía corta
====================

1) Motivo
- Exporta sólo el resumen estructurado en lugar de todo el chat para ahorrar tokens y proteger privacidad.

2) Campos recomendados
- `participants`, `messages_by_hour` (24 ints), `peak_hour`, `summary` (top_words, top_emojis, sentiment).

3) Ejemplo de prompt (español)
```
Objetivo: Resumir en 3-4 frases la actividad del grupo y proponer 2 acciones.
Entrada: JSON compacto con participantes y summary.
Salida: Texto en español con 3-4 frases y 2 acciones.

JSON:
<pega aquí JSON compacto>
```

4) Privacidad
- Anonimiza antes de enviar. No envíes mensajes enteros salvo que sea necesario.

5) Actualizar la guía
- Mantén `docs/AI_USAGE_AND_PROMPTS.md` sincronizada cuando cambies el esquema de export.
