#!/bin/bash
set -e

APP_NAME="ChatAnalyzer"
EXECUTABLE_NAME="chat_analyzer_ui"
BUILD_DIR="build/linux/x64/release/bundle"
APPDIR="$APP_NAME.AppDir"
ICONS_DIR="linux/icons"
ICON_BASE_NAME="io.xeland314.chat_analyzer_ui"
ICON_SOURCE_FILE="io.xeland314.chat_analyzer_ui.png"

# 1️⃣ Preparar estructura
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/icons/hicolor"

# 2️⃣ Copiar archivos y librerías
cp -r "$BUILD_DIR/"* "$APPDIR/usr/bin/"
LIBSTDCXX_PATH="/usr/lib/x86_64-linux-gnu/libstdc++.so.6"
if [ -f "$LIBSTDCXX_PATH" ]; then
  cp "$LIBSTDCXX_PATH" "$APPDIR/usr/lib/"
fi

# 3️⃣ Iconos (mismo proceso que antes)
find "$ICONS_DIR" -type d -name '*x*' | while read SIZE_DIR; do
  SIZE=$(basename "$SIZE_DIR")
  TARGET_DIR="$APPDIR/usr/share/icons/hicolor/$SIZE/apps"
  mkdir -p "$TARGET_DIR"
  cp "$SIZE_DIR/$ICON_SOURCE_FILE" "$TARGET_DIR/$ICON_BASE_NAME.png"
done
cp "$ICONS_DIR/256x256/$ICON_SOURCE_FILE" "$APPDIR/$ICON_BASE_NAME.png"

# 4️⃣ Crear AppRun INTELIGENTE
cat >"$APPDIR/AppRun" <<EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\$HERE/usr/lib:\$HERE/usr/bin:\$LD_LIBRARY_PATH"

# Intentar ejecución normal (usando la GPU si es posible)
echo "Intentando ejecución con aceleración de hardware..."
if "\$HERE/usr/bin/$EXECUTABLE_NAME" "\$@"; then
    exit 0
else
    EXIT_CODE=\$?
    echo "Fallo detectado (Código \$EXIT_CODE). Activando bypass para hardware antiguo..."
    
    # --- ACTIVAR BYPASS ANTES DE CUALQUIER OTRA COSA ---
    export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe
    export GALLIUM_DRIVER=llvmpipe
    export MESA_GL_VERSION_OVERRIDE=3.3
    export MESA_GLSL_VERSION_OVERRIDE=330

    # Ahora Zenity usará llvmpipe y no dará errores de contexto GL
    TITLE="ChatAnalyzer - Modo Compatibilidad"
    MSG="Tu hardware antiguo no soporta OpenGL 3.3 de forma nativa.\nIniciando con renderizado por software (CPU)..."

    if command -v zenity >/dev/null; then
        zenity --info --title="\$TITLE" --text="\$MSG" --timeout=10 --no-wrap &
    elif command -v kdialog >/dev/null; then
        kdialog --title "\$TITLE" --passivepopup "\$MSG" 10 &
    fi
    
    # Alternativa ultra-ligera si Zenity molesta mucho:
    if command -v notify-send >/dev/null; then
        notify-send "ChatAnalyzer" "Iniciando en modo compatibilidad" -i "$ICON_BASE_NAME"
    fi

    # Ejecutar la app (ya con el entorno de software configurado)
    exec "\$HERE/usr/bin/$EXECUTABLE_NAME" "\$@"
fi
EOF
chmod +x "$APPDIR/AppRun"

# 5️⃣ Desktop file y 6️⃣ Generar AppImage (Igual que antes)
cat >"$APPDIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$EXECUTABLE_NAME
Icon=$ICON_BASE_NAME
Type=Application
Categories=Utility;
StartupWMClass=ChatAnalyzer
EOF

appimagetool "$APPDIR"
