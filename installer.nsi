; Chat Analyzer UI - Instalador NSIS
!include "MUI2.nsh"
!include "x64.nsh"

; Configuración del Producto
!define PRODUCT_NAME "Chat Analyzer"
!define PRODUCT_VERSION "1.1.0"
!define PRODUCT_PUBLISHER "Christopher Villamarín - @xeland314"
!define PRODUCT_WEB_SITE "https://xeland314.github.io"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\chat_analyzer_ui.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

; Forzar ejecución como administrador
RequestExecutionLevel admin

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "ChatAnalyzerUI-Setup-v${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}"
ShowInstDetails show
ShowUnInstDetails show

VIProductVersion "${PRODUCT_VERSION}.0"
VIAddVersionKey ProductName "${PRODUCT_NAME}"
VIAddVersionKey ProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey CompanyName "${PRODUCT_PUBLISHER}"
VIAddVersionKey FileVersion "${PRODUCT_VERSION}"
VIAddVersionKey FileDescription "Chat Analyzer - Analizador de Chats"
VIAddVersionKey LegalCopyright "© 2025"
VIAddVersionKey OriginalFilename "ChatAnalyzer-Setup-v${PRODUCT_VERSION}.exe"

; Variable para guardar la carpeta del menú inicio
Var StartMenuFolder

; Páginas MUI
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY

; Página custom para el menú inicio
Page custom StartMenuGroupSelect "" ": Start Menu Folder"

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "English"

; --- Función de selección del menú inicio ---
Function StartMenuGroupSelect
  Push $R1
  StartMenu::Select /checknoshortcuts "No crear acceso en el menú inicio" \
    /autoadd /lastused $StartMenuFolder "${PRODUCT_NAME}"
  Pop $R1

  StrCmp $R1 "success" success
  StrCmp $R1 "cancel" done
    ; Error: usar carpeta por defecto
    MessageBox MB_OK "Error al seleccionar carpeta: $R1"
    StrCpy $StartMenuFolder "${PRODUCT_NAME}"
    Return
  success:
    Pop $StartMenuFolder
  done:
  Pop $R1
FunctionEnd

; --- Función init ---
Function .onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${Else}
    MessageBox MB_OK "Este instalador requiere Windows de 64 bits"
    Abort
  ${EndIf}
FunctionEnd

; --- Sección de instalación ---
Section "Instalar"
  SetOverwrite try
  SetOutPath "$INSTDIR"

  File "build\windows\x64\runner\Release\chat_analyzer_ui.exe"
  File "LICENSE"
  File /r /x "*.pdb" /x "*.lib" "build\windows\x64\runner\Release\*.*"

  WriteUninstaller "$INSTDIR\uninstall.exe"

  ; Menú inicio (solo si el usuario no marcó "no crear")
  StrCpy $R1 $StartMenuFolder 1
  StrCmp $R1 ">" skip_startmenu

    SetShellVarContext all
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\${PRODUCT_NAME}.lnk" \
      "$INSTDIR\chat_analyzer_ui.exe" "" \
      "$INSTDIR\chat_analyzer_ui.exe" 0 SW_SHOWNORMAL "" "${PRODUCT_NAME}"
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Desinstalar.lnk" \
      "$INSTDIR\uninstall.exe" "" \
      "$INSTDIR\uninstall.exe" 0 SW_SHOWNORMAL "" "Desinstalar ${PRODUCT_NAME}"

  skip_startmenu:

  ; Escritorio (para todos los usuarios)
  SetShellVarContext all
  CreateShortcut "$DESKTOP\${PRODUCT_NAME}.lnk" \
    "$INSTDIR\chat_analyzer_ui.exe" "" \
    "$INSTDIR\chat_analyzer_ui.exe" 0 SW_SHOWNORMAL "" "${PRODUCT_NAME}"

  ; Registro de Windows
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\chat_analyzer_ui.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\chat_analyzer_ui.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegDWord HKLM "${PRODUCT_UNINST_KEY}" "NoModify" 1
  WriteRegDWord HKLM "${PRODUCT_UNINST_KEY}" "NoRepair" 1

SectionEnd

; --- Desinstalación ---
Section "Desinstalar"
  RMDir /r "$INSTDIR"
  SetShellVarContext all
  RMDir /r "$SMPROGRAMS\${PRODUCT_NAME}"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
SectionEnd