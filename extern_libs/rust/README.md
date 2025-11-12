# Chat Rust Parser

Librería nativa en Rust para parsing ultra-rápido de chats de WhatsApp con análisis de sentimiento.

## 🚀 Características

- **10-100x más rápido** que el parser de Dart
- Análisis de sentimiento integrado
- Soporte para mensajes multilínea
- Compatible con Android y Linux

## 📋 Requisitos

### Para Linux
```bash
rustup target add x86_64-unknown-linux-gnu
```

### Para Android
```bash
# Instalar Rust targets
rustup target add aarch64-linux-android   # ARM64
rustup target add armv7-linux-androideabi # ARMv7
rustup target add x86_64-linux-android    # x86_64

# Instalar cargo-ndk
cargo install cargo-ndk

# Configurar NDK (si no lo tienes)
# Descargar desde: https://developer.android.com/ndk/downloads
export ANDROID_NDK_HOME=/path/to/ndk
```

## 📁 Estructura

```
rust/
├── src/
│   └── lib.rs           # Código principal
├── Cargo.toml           # Dependencias
├── build.sh             # Script de compilación
└── target/              # Binarios compilados (gitignore)
```

## 🧪 Tests

```bash
cargo test
```

## 📊 Benchmark

```bash
cargo bench
```

## 🔍 Debugging

Para ver logs detallados durante la compilación:
```bash
RUST_LOG=debug cargo build --release
```

## 📝 Notas

- Los binarios se copian automáticamente a:
  - `../android/app/src/main/jniLibs/` (Android)
  - `../linux/lib/` (Linux)
- Después de compilar, ejecuta `flutter clean` antes de rebuild

## 🐛 Troubleshooting

### Error: "NDK not found"
```bash
export ANDROID_NDK_HOME=$HOME/Android/Sdk/ndk/25.1.8937393
```

### Error: "target not installed"
```bash
rustup target add <target-name>
```

### Performance no mejora
- Verifica que estés compilando en `--release`
- Confirma que Flutter está cargando la librería nativa (revisa logs)
