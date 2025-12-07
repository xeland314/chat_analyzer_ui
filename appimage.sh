#!/bin/bash
set -e

APP_NAME="ChatAnalyzer"
EXECUTABLE_NAME="chat_analyzer_ui"
BUILD_DIR="build/linux/x64/release/bundle"
APPDIR="$APP_NAME.AppDir"
ICONS_DIR="linux/icons"
ICON_BASE_NAME="io.xeland314.chat_analyzer_ui" # Nombre base del icono, sin extensión ni tamaño
ICON_SOURCE_FILE="app_icon.png"

# 1️⃣ Limpiar y preparar la estructura de directorios estándar de AppImage
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/icons/hicolor"

# 2️⃣ Copiar binarios y bibliotecas
cp -r "$BUILD_DIR/"* "$APPDIR/usr/bin/"

# 3️⃣ Copiar Iconos según la Especificación FreeDesktop (hicolor)
find "$ICONS_DIR" -type d -name '*x*' | while read SIZE_DIR; do
    SIZE=$(basename "$SIZE_DIR") 
    
    TARGET_DIR="$APPDIR/usr/share/icons/hicolor/$SIZE/apps"
    mkdir -p "$TARGET_DIR"
    
    # Copia Específica: Origen (e.g., /128x128/app_icon.png) a Destino (e.g., /128x128/apps/io.xeland314.chat_analyzer_ui.png)
    cp "$SIZE_DIR/$ICON_SOURCE_FILE" "$TARGET_DIR/$ICON_BASE_NAME.png"
done

# 4️⃣ Renombrar y copiar el icono principal a la raíz (para el ícono del AppImage)
# Elige un tamaño principal, por ejemplo 256x256
cp "$ICONS_DIR/256x256/$ICON_SOURCE_FILE" "$APPDIR/$ICON_BASE_NAME.png" # ⬅️ Ajuste aquí también

# 5️⃣ Crear AppRun
cat > "$APPDIR/AppRun" <<EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\$HERE/usr/bin:\$LD_LIBRARY_PATH"
exec "\$HERE/usr/bin/$EXECUTABLE_NAME" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

# 6️⃣ Crear archivo desktop
cat > "$APPDIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$EXECUTABLE_NAME
Icon=$ICON_BASE_NAME 
Type=Application
Categories=Utility;
EOF

# 7️⃣ Generar AppImage
appimagetool "$APPDIR"
