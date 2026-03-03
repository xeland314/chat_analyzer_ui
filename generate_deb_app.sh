#!/bin/bash
set -e

# Variables (Mantenemos las tuyas)
APP_NAME="chatanalyzer" # En .deb se recomienda usar minúsculas
EXECUTABLE_NAME="chat_analyzer_ui"
BUILD_DIR="build/linux/x64/release/bundle"
DEB_ROOT="chatanalyzer_1.0.0_amd64" # Nombre de la carpeta de construcción
ICONS_DIR="linux/icons"
ICON_BASE_NAME="io.xeland314.chat_analyzer_ui"
ICON_SOURCE_FILE="io.xeland314.chat_analyzer_ui.png"

# 1️⃣ Limpiar y crear estructura
rm -rf "$DEB_ROOT"
mkdir -p "$DEB_ROOT/DEBIAN"
mkdir -p "$DEB_ROOT/usr/bin"
mkdir -p "$DEB_ROOT/usr/lib/$APP_NAME"
mkdir -p "$DEB_ROOT/usr/share/applications"

# 2️⃣ Crear el archivo CONTROL (Metadatos)
cat >"$DEB_ROOT/DEBIAN/control" <<EOF
Package: $APP_NAME
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Tu Nombre <tu@email.com>
Description: Analizador de chats hecho en Flutter.
 Incluye bypass para hardware antiguo (llvmpipe).
Depends: libgtk-3-0, libblkid1, liblzma5, zenity
EOF

# 3️⃣ Copiar binarios y librerías de Flutter
# Los binarios de Flutter suelen ir mejor en un subdirectorio de /usr/lib
cp -r "$BUILD_DIR/"* "$DEB_ROOT/usr/lib/$APP_NAME/"

# 4️⃣ Crear el script de lanzamiento "Inteligente" en /usr/bin
# Este script reemplaza al AppRun del AppImage
cat >"$DEB_ROOT/usr/bin/$APP_NAME" <<EOF
#!/bin/bash
# Ruta donde están las librerías de la app
LIB_PATH="/usr/lib/$APP_NAME"
export LD_LIBRARY_PATH="\$LIB_PATH:\$LIB_PATH/lib:\$LD_LIBRARY_PATH"

# Lógica de compatibilidad que ya tenías
if "\$LIB_PATH/$EXECUTABLE_NAME" "\$@"; then
    exit 0
else
    echo "Activando modo compatibilidad..."
    export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe
    export GALLIUM_DRIVER=llvmpipe
    export MESA_GL_VERSION_OVERRIDE=3.3
    export MESA_GLSL_VERSION_OVERRIDE=330
    
    if command -v zenity >/dev/null; then
        zenity --info --title="ChatAnalyzer" --text="Iniciando en modo software..." --timeout=5 &
    fi
    
    exec "\$LIB_PATH/$EXECUTABLE_NAME" "\$@"
fi
EOF
chmod +x "$DEB_ROOT/usr/bin/$APP_NAME"

# 5️⃣ Iconos (Tu lógica de búsqueda de tamaños)
find "$ICONS_DIR" -type d -name '*x*' | while read SIZE_DIR; do
  SIZE=$(basename "$SIZE_DIR")
  TARGET_DIR="$DEB_ROOT/usr/share/icons/hicolor/$SIZE/apps"
  mkdir -p "$TARGET_DIR"
  cp "$SIZE_DIR/$ICON_SOURCE_FILE" "$TARGET_DIR/$ICON_BASE_NAME.png"
done

# 6️⃣ Archivo .desktop
cat >"$DEB_ROOT/usr/share/applications/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=ChatAnalyzer
Exec=$APP_NAME
Icon=$ICON_BASE_NAME
Type=Application
Categories=Utility;
Terminal=false
EOF

# 7️⃣ Empaquetar
chmod 755 "$DEB_ROOT/DEBIAN"
chmod 644 "$DEB_ROOT/DEBIAN/control"
dpkg-deb --build "$DEB_ROOT"
echo "¡Hecho! Archivo $DEB_ROOT.deb creado."
