#!/bin/bash
set -e

APP_NAME="ChatAnalyzer"
BUILD_DIR="build/linux/x64/release/bundle"
APPDIR="$APP_NAME.AppDir"

# 1️⃣ Limpiar AppDir antiguo
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"

# 2️⃣ Copiar todo el contenido del bundle
cp -r "$BUILD_DIR/"* "$APPDIR/usr/bin/"

# 3️⃣ Copiar icono y renombrarlo para AppImage
cp "$BUILD_DIR/data/flutter_assets/assets/pixel-cat.png" "$APPDIR/ChatAnalyzer.png"

# 4️⃣ Crear AppRun
cat > "$APPDIR/AppRun" <<EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\$HERE/usr/bin:\$LD_LIBRARY_PATH"
exec "\$HERE/usr/bin/chat_analyzer_ui" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

# 5️⃣ Crear archivo desktop
cat > "$APPDIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=chat_analyzer_ui
Icon=$APP_NAME
Type=Application
Categories=Utility;
EOF

# 6️⃣ Generar AppImage
appimagetool "$APPDIR"
