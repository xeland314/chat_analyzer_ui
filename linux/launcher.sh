#!/bin/bash
# Ruta dentro del contenedor Flatpak
export LD_LIBRARY_PATH="/app/share/chatanalyzer/lib:$LD_LIBRARY_PATH"

if /app/share/chatanalyzer/chat_analyzer_ui "$@"; then
    exit 0
else
    export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe
    export GALLIUM_DRIVER=llvmpipe
    exec /app/share/chatanalyzer/chat_analyzer_ui "$@"
fi
