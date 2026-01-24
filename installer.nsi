; Chat Analyzer UI - Instalador NSIS
; Este script genera un instalador profesional para Windows

!include "MUI2.nsh"
!include "x64.nsh"

; Configuración del Producto
!define PRODUCT_NAME "Chat Analyzer"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "Christopher Villamarín - @xeland314"
!define PRODUCT_WEB_SITE "https://xeland314.github.io"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\chat_analyzer_ui.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

; Configuración del Instalador
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "ChatAnalyzerUI-Setup-v${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}"
ShowInstDetails show
ShowUnInstDetails show

; Información de Versión
VIProductVersion "${PRODUCT_VERSION}.0"
VIAddVersionKey ProductName "${PRODUCT_NAME}"
VIAddVersionKey ProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey CompanyName "${PRODUCT_PUBLISHER}"
VIAddVersionKey FileVersion "${PRODUCT_VERSION}"
VIAddVersionKey FileDescription "Chat Analyzer - Analizador de Chats"
VIAddVersionKey LegalCopyright "© 2025"
VIAddVersionKey OriginalFilename "ChatAnalyzer-Setup-v${PRODUCT_VERSION}.exe"

; Interfaz MUI
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Página de desinstalación
!insertmacro MUI_UNPAGE_INSTFILES

; Idioma
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "English"

; Funciones
Function .onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${Else}
    MessageBox MB_OK "Este instalador requiere Windows de 64 bits"
    Abort
  ${EndIf}
FunctionEnd

; Instalación
Section "Instalar"
  SetOverwrite try
  SetOutPath "$INSTDIR"
  
  ; Copiar el ejecutable
  File "build\windows\x64\runner\Release\chat_analyzer_ui.exe"
  ; Incluir archivo de licencia en la instalación
  File "LICENSE"
  
  ; Copiar archivos necesarios de Flutter (si existen)
  File /r /x "*.pdb" /x "*.lib" "build\windows\x64\runner\Release\*.*"
  
  ; Crear desinstalador
  WriteUninstaller "$INSTDIR\uninstall.exe"

    ; Selección de carpeta del Menú Inicio usando StartMenu plugin
    ; Si el usuario selecciona una carpeta se crearán los accesos ahí.
    ; Si cancela o hay error, se usará la carpeta por defecto "$SMPROGRAMS\${PRODUCT_NAME}"
    StartMenu::Select /autoadd "${PRODUCT_NAME}"
    Pop $0
    StrCmp $0 "success" 0 +6
      Pop $1 ; carpeta seleccionada (subfolder)
      StrCpy $2 $1 1 0
      StrCmp $2 ">" 0 +4
        ; Usuario marcó 'no shortcuts' -> no crear accesos
        Goto _SKIP_SHORTCUTS
      ; Construir ruta completa y crear carpeta
      StrCpy $3 "$SMPROGRAMS\\$1"
      CreateDirectory "$3"
      CreateShortcut "$3\\${PRODUCT_NAME}.lnk" "$INSTDIR\\chat_analyzer_ui.exe" "" "$INSTDIR\\chat_analyzer_ui.exe" 0 SW_SHOWNORMAL "" "${PRODUCT_NAME}"
      CreateShortcut "$3\\Desinstalar.lnk" "$INSTDIR\\uninstall.exe" "" "$INSTDIR\\uninstall.exe" 0 SW_SHOWNORMAL "" "Desinstalar ${PRODUCT_NAME}"
      Goto _SHORTCUTS_DONE

    ; No success (cancel or error) -> usar carpeta por defecto
    CreateDirectory "$SMPROGRAMS\\${PRODUCT_NAME}"
    CreateShortcut "$SMPROGRAMS\\${PRODUCT_NAME}\\${PRODUCT_NAME}.lnk" "$INSTDIR\\chat_analyzer_ui.exe" "" "$INSTDIR\\chat_analyzer_ui.exe" 0 SW_SHOWNORMAL "" "${PRODUCT_NAME}"
    CreateShortcut "$SMPROGRAMS\\${PRODUCT_NAME}\\Desinstalar.lnk" "$INSTDIR\\uninstall.exe" "" "$INSTDIR\\uninstall.exe" 0 SW_SHOWNORMAL "" "Desinstalar ${PRODUCT_NAME}"

    ; Crear acceso directo en el escritorio (usuario actual)
    CreateShortcut "$DESKTOP\\${PRODUCT_NAME}.lnk" "$INSTDIR\\chat_analyzer_ui.exe" "" "$INSTDIR\\chat_analyzer_ui.exe" 0 SW_SHOWNORMAL "" "${PRODUCT_NAME}"

    Goto _SHORTCUTS_DONE

    _SKIP_SHORTCUTS:
      ; El usuario solicitó no crear accesos en el menú
      ; No hacemos nada

    _SHORTCUTS_DONE:
  
  ; Registro de Windows
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\chat_analyzer_ui.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\chat_analyzer_ui.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  
  ; Registrar la app en "Programas instalados"
  WriteRegDWord HKLM "${PRODUCT_UNINST_KEY}" "NoModify" 1
  WriteRegDWord HKLM "${PRODUCT_UNINST_KEY}" "NoRepair" 1

SectionEnd

; Desinstalación
Section "Desinstalar"
  ; Eliminar archivos
  RMDir /r "$INSTDIR"
  
  ; Eliminar accesos directos
  RMDir /r "$SMPROGRAMS\${PRODUCT_NAME}"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  
  ; Limpiar registro
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"

SectionEnd
