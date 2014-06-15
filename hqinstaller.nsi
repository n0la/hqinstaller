/* Simple yet functional installer for the Halfquake series of mods.
 * Works only with installed Steam and Half-Life Steam Edition.
 *
 * Installer Copyright (C) 2014 Florian Stinglmayr <florian@n0la.org>
 * Halfquake, Halfquake: Amen, Halfquake: Sunrise Copyright (C) 2001 Philipp Lehner <muddasheep@gmail.com>
 */
 
!include "LogicLib.nsh"
!include "nsDialogs.nsh"
!include "MUI2.nsh"
!include "Sections.nsh"

!define MUI_ICON "hq_trilogy.ico"
!define MUI_UNICON "hq_trilogy.ico"

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "header_top.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "header_left.bmp"
!define MUI_BGCOLOR FFFFFF

OutFile "hqinstaller.exe"
Name "Halfquake Trilogy"
RequestExecutionLevel admin

Var HalfLifePath
!define MUI_DIRECTORYPAGE_VARIABLE $HalfLifePath
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!define MUI_FINISHPAGE_LINK "Visit The Farm for further information"
!define MUI_FINISHPAGE_LINK_LOCATION "http://farm.muddasheep.com/"
!define MUI_FINISHPAGE_TEXT "You are now ready to die multiple times!"

Var NoSteam
Var NoHalfLife

Function FindHalfLife
  ReadRegStr $0 HKCU "SOFTWARE\Valve\Steam" SteamPath
  GetFullPathName $0 "$0"
  StrCmp $0 "" NoSteam CheckHalfLife
  
NoSteam:
  StrCpy $NoSteam "1"
  DetailPrint "No Steam installation found."
  Return
  
CheckHalfLife:
  DetailPrint "Found Steam in $0"

  StrCpy $HalfLifePath "$0\steamapps\common\Half-Life"
  IfFileExists $HalfLifePath Done NoHalfLife

NoHalfLife:
  StrCpy $NoHalfLife "1"
  MessageBox MB_OK "I was unable to find an Half-Life installation for you.$\r$\nPlease specify the path to your hl.exe in the next window."
  DetailPrint "No Half-Life installation found."
  Return
  
Done:
  DetailPrint "Found Half-Life in: $HalfLifePath"
  Return
FunctionEnd

SectionGroup "Halfquake Series" HQSeries

   Section "Halfquake" HQUAKE1
    SectionIn 1 2
  
    SetOutPath "$HalfLifePath"
    File /r "hquake"
    CreateShortCut "$DESKTOP\Halfquake.lnk" "$HalfLifePath\hl.exe" "-game hquake" "$HalfLifePath\hquake\hq_icon.ico" 0
  SectionEnd

  Section "Halfquake: Amen" HQUAKE2
    SectionIn 1
  
    SetOutPath "$HalfLifePath"
    File /r "hquake2"
    CreateShortCut "$DESKTOP\Halfquake: Amen.lnk" "$HalfLifePath\hl.exe" "-game hquake2" "$HalfLifePath\hquake2\hqa_icon.ico" 0
  SectionEnd

  Section "Halfquake: Sunrise" HQUAKE3
    SectionIn 1
  
    SetOutPath "$HalfLifePath"
    File /r "hquake3"
    CreateShortCut "$DESKTOP\Halfquake: Sunrise.lnk" "$HalfLifePath\hl.exe" "-game hquake3" "$HalfLifePath\hquake3\hqs_icon.ico" 0
  SectionEnd
  
  # Hidden section for common files.
  Section "-Common"
    SectionGetFlags ${HQUAKE1} $0
    IntOp $0 $0 & ${SF_SELECTED}
    IntOp $1 $1 + $0

    SectionGetFlags ${HQUAKE2} $0
    IntOp $0 $0 & ${SF_SELECTED}
    IntOp $1 $1 + $0
    
    SectionGetFlags ${HQUAKE3} $0
    IntOp $0 $0 & ${SF_SELECTED}
    IntOp $1 $1 + $0
    
    ${IF} $1 > 0
      SetOutPath $HalfLifePath
      File "cg.dll"
      File "cgGL.dll"
      
      # Create uninstaller
      WriteUninstaller "$HalfLifePath\hquninstaller.exe"
    ${ELSE}
      MessageBox MB_OK "No Halfquake MOD selected :-("
      Quit
    ${ENDIF}
  SectionEnd

SectionGroupEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${HQSeries} "The Halfquake series."
  !insertmacro MUI_DESCRIPTION_TEXT ${HQUAKE1} "The first part of the series; how it all began."
  !insertmacro MUI_DESCRIPTION_TEXT ${HQUAKE2} "Halfquake: Amen. Now with 100% more sadism."
  !insertmacro MUI_DESCRIPTION_TEXT ${HQUAKE3} "Halfquake: Sunrise - Pain and suffering brought to ludicrous levels."
!insertmacro MUI_FUNCTION_DESCRIPTION_END


Section "Uninstall"
  Delete "$INSTDIR\hquninstaller.exe"
  # Delete mod folders.
  RMDir /r "$INSTDIR\hquake"
  RMDir /r "$INSTDIR\hquake2"
  RMDir /r "$INSTDIR\hquake3"
  # Delete common files.
  Delete "$INSTDIR\cg.dll"
  Delete "$INSTDIR\cgGL.dll"
  
  Delete "$DESKTOP\Halfquake*.lnk"
SectionEnd

Function .onInit
  SectionSetFlags ${HQUAKE1} ${SF_SELECTED}
  SectionSetFlags ${HQUAKE2} ${SF_SELECTED}
  SectionSetFlags ${HQUAKE3} ${SF_SELECTED}

  Call FindHalfLife
FunctionEnd

!insertmacro MUI_LANGUAGE "English"