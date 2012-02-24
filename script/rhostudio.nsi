;======================================================
; Include
 
  !include "MUI.nsh"
  !include "LogicLib.nsh"
  !include "%NSIS_SCRIPT_PATH%\EnvVarUpdate.nsh"
 
;======================================================
; Installer Information
 
  Name "RhoStudio Installer"
  OutFile "RhoStudioInstaller.exe"
  InstallDir C:\RhoStudio
  BrandingText " "
;======================================================
; Modern Interface Configuration
 
  !define MUI_ICON "icon.ico" 
  !define MUI_UNICON "icon.ico"     
  !define MUI_HEADERIMAGE
  !define MUI_ABORTWARNING
  !define MUI_COMPONENTSPAGE_SMALLDESC
  !define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
  !define MUI_FINISHPAGE_SHOWREADME $INSTDIR\README.html
  !define MUI_FINISHPAGE
  !define MUI_FINISHPAGE_TEXT "Thank you for installing Rhodes, Rhoconnect and RhoStudio. \r\n\n\n"
 
 
;======================================================
; Pages
 
  !insertmacro MUI_PAGE_WELCOME
  !define MUI_PAGE_HEADER_TEXT "RhoStudio License Agreement"
  !define MUI_PAGE_HEADER_SUBTEXT "Please review the RhoStudio license terms before installing."
  !insertmacro MUI_PAGE_LICENSE "RHOSTUDIO-LICENSE.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  #Page custom customerConfig
  !insertmacro MUI_PAGE_FINISH
 
;======================================================
; Languages
 
  !insertmacro MUI_LANGUAGE "English"
 
;======================================================
; Reserve Files
 
  ReserveFile "%NSIS_SCRIPT_PATH%\configUi.ini"
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;======================================================
; Variables
 # var varApacheEmail
 # var varApachePort
  var varDbPass

;======================================================
; Sections

# start default section
section

    ReadRegStr $0 HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\javaws.exe" "Path"
              
    StrCmp $0 "" jreInstallFail   
     
    # set the installation directory as the destination for the following actions
    setOutPath $INSTDIR
 
    # create the uninstaller
    writeUninstaller "$INSTDIR\uninstall.exe"
 
    SetOutPath "$SMPROGRAMS\RhoStudio"
    
    # create a shortcut named "new shortcut" in the start menu programs directory
    # point the new shortcut at the program uninstaller
    createShortCut "$SMPROGRAMS\RhoStudio\Uninstall RhoStudio.lnk" "$INSTDIR\uninstall.exe"
    createShortCut "$SMPROGRAMS\RhoStudio\RhoStudio.lnk" "$INSTDIR\eclipse\RhoStudio.exe"

    # added information in 'unistall programs' in contorol panel
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RhoStudio" \
                 "DisplayName" "RhoStudio - RAD tool for develop and debug rhodes/rhoconnect applications"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RhoStudio" \
                 "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RhoStudio" \
                 "DisplayIcon" "$\"$INSTDIR\uninstall.exe$\""
    
    Goto okFinishSection
    
    jreInstallFail:
        MessageBox MB_OK|MB_ICONINFORMATION|MB_DEFBUTTON1 "Java Runtime Environment could not be found on your computer. Please install Java Runtime Environment before RhoStudio."
        Quit 

    okFinishSection: 
sectionEnd
 
# uninstaller section start
section "uninstall"
 
    # first, delete the uninstaller
    delete "$INSTDIR\uninstall.exe"
 
    # second, remove the link from the start menu    
    delete "$SMPROGRAMS\RhoStudio\Uninstall RhoStudio.lnk"
    delete "$SMPROGRAMS\RhoStudio\RhoStudio.lnk"
    delete "$SMPROGRAMS\RhoStudio"

    ExecWait 'net stop redis'
    ExecWait 'sc delete redis'

    # remove env vars
    Push "PATH" 
    Push "R" 
    Push "HKLM" 
    Push "$INSTDIR\ruby\bin"
    Call un.EnvVarUpdate
    Pop $R0

    Push "PATH" 
    Push "R" 
    Push "HKLM" 
    Push "$INSTDIR\make-3.81\bin"
    Call un.EnvVarUpdate
    Pop $R0

    Push "PATH" 
    Push "R" 
    Push "HKLM" 
    Push "$INSTDIR\redis-2.4.0"
    Call un.EnvVarUpdate
    Pop $R0

    Push "PATH" 
    Push "R" 
    Push "HKLM" 
    Push "$INSTDIR\devkit\mingw\bin"
    Call un.EnvVarUpdate
    Pop $R0

    Push "PATH" 
    Push "R" 
    Push "HKLM" 
    Push "$INSTDIR\devkit\bin"
    Call un.EnvVarUpdate
    Pop $R0

    DeleteRegValue HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" REDIS_HOME
    DeleteRegKey HKLM  "Software\Microsoft\Windows\CurrentVersion\Uninstall\RhoStudio"

    # remove $INSTDIR
    RMDir /r /REBOOTOK $INSTDIR

# uninstaller section end
sectionEnd

Section "GNU Make" gnumakeSection

  SetOutPath $INSTDIR
 
  File /r "make-3.81"

  Push "PATH" 
  Push "P" 
  Push "HKLM" 
  Push "$INSTDIR\make-3.81\bin"
  Call EnvVarUpdate
  Pop $R0

SectionEnd

Section "RhoStudio" studioSection
 
  SetOutPath $INSTDIR
 
  File /r "eclipse"

SectionEnd

Section "Samples" samplesSection
 
  SetOutPath $INSTDIR
 
  File /r "samples"

SectionEnd

Section "DevKit" devkitSection
 
  SetOutPath $INSTDIR
 
  File /r "devkit"

  Push "PATH" 
  Push "P" 
  Push "HKLM" 
  Push "$INSTDIR\devkit\mingw\bin"
  Call EnvVarUpdate
  Pop $R0

  Push "PATH" 
  Push "P" 
  Push "HKLM" 
  Push "$INSTDIR\devkit\bin"
  Call EnvVarUpdate
  Pop $R0
  
SectionEnd

Section "Ruby, Rubygems, Rhodes, Rhoconnect and adapters" rubySection
 
  SetOutPath $INSTDIR
 
  File /r "ruby"
  File /r "make-3.81"

  File "README.html"
  File "RHOSTUDIO-LICENSE.txt"
 
  ;add to path here

  Push "PATH" 
  Push "P" 
  Push "HKLM" 
  Push "$INSTDIR\ruby\bin"
  Call EnvVarUpdate
  Pop $R0

SectionEnd

Section "Redis" redisSection
 
  SetOutPath $INSTDIR
 
  File /r "redis-2.4.0"
 
  ;add to path here

  Push "PATH" 
  Push "P" 
  Push "HKLM" 
  Push "$INSTDIR\redis-2.4.0"
  Call EnvVarUpdate
  Pop $R0

  Push "REDIS_HOME" 
  Push "P" 
  Push "HKLM" 
  Push "$INSTDIR\redis-2.4.0"
  Call EnvVarUpdate
  Pop $R0

  ExecWait "$INSTDIR\ruby\bin\rake.bat redis:install"
  
SectionEnd

Section "Git 1.7.6" gitSection

  SetOutPath $INSTDIR
  
  File "Git-1.7.6-preview20110708.exe"
 
  ExecWait "$INSTDIR\Git-1.7.6-preview20110708.exe"

  delete "$INSTDIR\Git-1.7.6-preview20110708.exe"

SectionEnd


#Section "Java SE Runtime Environment 6 Update 26" javaSection

#  SetOutPath $INSTDIR
  
#  File "jre-6u26-windows-i586.exe"
 
#  ExecWait "$INSTDIR\jre-6u26-windows-i586.exe"

#  delete "$INSTDIR\jre-6u26-windows-i586.exe"

#SectionEnd

;======================================================
;Descriptions
 
  ;Language strings
  LangString DESC_InstallRhostudio ${LANG_ENGLISH} "This installs Eclipse with RhoStudio."
  #LangString DESC_InstallApache ${LANG_ENGLISH} "This installs the Apache 2.2 webserver"
  LangString DESC_InstallRuby ${LANG_ENGLISH} "This installs ruby 1.8.7, rubygems 1.3.7, Rhodes, Rhoconnect and adapters"
  LangString DESC_InstallRedis ${LANG_ENGLISH} "This installs redis 2.2.2 (required to run Rhoconnect)."
  LangString DESC_InstallGit ${LANG_ENGLISH} "This installs Git (which includes the Git Bash)."
  LangString DESC_InstallGnuMake ${LANG_ENGLISH} "This installs GNU Make (sometimes required to update gems)."
  LangString DESC_InstallSamples ${LANG_ENGLISH} "This installs samples for rhodes."
  LangString DESC_InstallDevKit ${LANG_ENGLISH} "This installs samples for rhodes."  
  #LangString DESC_InstallJava ${LANG_ENGLISH} "This installs Java SE Runtime Environment."  
  
  ;Assign language strings to sections
  
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${studioSection} $(DESC_InstallRhostudio)
  #!insertmacro MUI_DESCRIPTION_TEXT ${apache2Section} $(DESC_InstallApache)
  !insertmacro MUI_DESCRIPTION_TEXT ${gnumakeSection} $(DESC_InstallGnuMake)
  !insertmacro MUI_DESCRIPTION_TEXT ${devkitSection} $(DESC_InstallDevKit)
  !insertmacro MUI_DESCRIPTION_TEXT ${rubySection} $(DESC_InstallRuby) 
  !insertmacro MUI_DESCRIPTION_TEXT ${redisSection} $(DESC_InstallRedis)
  !insertmacro MUI_DESCRIPTION_TEXT ${gitSection} $(DESC_InstallGit)
  !insertmacro MUI_DESCRIPTION_TEXT ${samplesSection} $(DESC_InstallSamples)
  #!insertmacro MUI_DESCRIPTION_TEXT ${javaSection} $(DESC_InstallJava)    
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;======================================================
;Functions
 
Function .onInit
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "%NSIS_SCRIPT_PATH%\configUi.ini"
FunctionEnd 

LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Configuration page"
LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "This page will update application files based on your system configuration."

Function FixScriptFilesInDir
Exch $R0 #path
Exch
Exch $R1 #filter
Exch
Exch 2
Exch $R2 #output file
Exch 2
Push $R3
Push $R4
Push $R5
Push $R6
 ClearErrors
 FindFirst $R3 $R4 "$R0\$R1"
  FileOpen $R5 $R2 w

 Push $INSTDIR
 Push "\"
 Call StrSlash
 Pop $R6 

 Loop:
 IfErrors Done
  StrCmp $R4 "." gotoNextFile
  StrCmp $R4 ".." gotoNextFile

  ;replace package folder with INSTDIR
  Push C:/dev/rhodesinstaller
  Push $R6
  Push all
  Push all
  Push "$R0\$R4"
  Call AdvReplaceInFile
  FileWrite $R5 "$R0\$R4$\r$\n"
  FindNext $R3 $R4
  Goto Loop

 gotoNextFile:
  FindNext $R3 $R4
  Goto Loop

 Done:
  FileClose $R5
 FindClose $R3
Pop $R6
Pop $R5
Pop $R4
Pop $R3
Pop $R2
Pop $R1
Pop $R0
FunctionEnd



Function AdvReplaceInFile
Exch $0 ;file to replace in
Exch
Exch $1 ;number to replace after
Exch
Exch 2
Exch $2 ;replace and onwards
Exch 2
Exch 3
Exch $3 ;replace with
Exch 3
Exch 4
Exch $4 ;to replace
Exch 4
Push $5 ;minus count
Push $6 ;universal
Push $7 ;end string
Push $8 ;left string
Push $9 ;right string
Push $R0 ;file1
Push $R1 ;file2
Push $R2 ;read
Push $R3 ;universal
Push $R4 ;count (onwards)
Push $R5 ;count (after)
Push $R6 ;temp file name
 
  GetTempFileName $R6
  FileOpen $R1 $0 r ;file to search in
  FileOpen $R0 $R6 w ;temp file
   StrLen $R3 $4
   StrCpy $R4 -1
   StrCpy $R5 -1
 
loop_read:
 ClearErrors
 FileRead $R1 $R2 ;read line
 IfErrors exit
 
   StrCpy $5 0
   StrCpy $7 $R2
 
loop_filter:
   IntOp $5 $5 - 1
   StrCpy $6 $7 $R3 $5 ;search
   StrCmp $6 "" file_write2
   StrCmp $6 $4 0 loop_filter
 
StrCpy $8 $7 $5 ;left part
IntOp $6 $5 + $R3
IntCmp $6 0 is0 not0
is0:
StrCpy $9 ""
Goto done
not0:
StrCpy $9 $7 "" $6 ;right part
done:
StrCpy $7 $8$3$9 ;re-join
 
IntOp $R4 $R4 + 1
StrCmp $2 all file_write1
StrCmp $R4 $2 0 file_write2
IntOp $R4 $R4 - 1
 
IntOp $R5 $R5 + 1
StrCmp $1 all file_write1
StrCmp $R5 $1 0 file_write1
IntOp $R5 $R5 - 1
Goto file_write2
 
file_write1:
 FileWrite $R0 $7 ;write modified line
Goto loop_read
 
file_write2:
 FileWrite $R0 $R2 ;write unmodified line
Goto loop_read
 
exit:
  FileClose $R0
  FileClose $R1
 
   SetDetailsPrint none
  Delete $0
  Rename $R6 $0
  Delete $R6
   SetDetailsPrint both
 
Pop $R6
Pop $R5
Pop $R4
Pop $R3
Pop $R2
Pop $R1
Pop $R0
Pop $9   
Pop $8
Pop $7
Pop $6
Pop $5
Pop $0
Pop $1
Pop $2
Pop $3
Pop $4
FunctionEnd 


; Push $filenamestring (e.g. 'c:\this\and\that\filename.htm')
; Push "\"
; Call StrSlash
; Pop $R0
; ;Now $R0 contains 'c:/this/and/that/filename.htm'
Function StrSlash
  Exch $R3 ; $R3 = needle ("\" or "/")
  Exch
  Exch $R1 ; $R1 = String to replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R4 ; $R4 = not $R3 ("/" or "\")
  Push $R6
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R6 $R1
  StrCpy $R4 "\"
  StrCmp $R3 "/" loop
  StrCpy $R4 "/"  
loop:
  StrCpy $R7 $R1 1
  StrCpy $R1 $R1 $R6 1
  StrCmp $R7 $R3 found
  StrCpy $R2 "$R2$R7"
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R4
  Pop $R2
  Pop $R1
  Exch $R3
FunctionEnd