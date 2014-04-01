/* Simple yet functional installer for the HalfQuake series of mods.
 * Works only with installed Steam and Half-Life Steam Edition.
 *
 * Installer Copyright (C) 2014 Florian Stinglmayr <florian@n0la.org>
 * HalfQuake, HalfQuake: Amen, HalfQuake: Sunrise Copyright (C) 2001 Philipp Lehner <muddasheep@gmail.com>
 */
 
!include LogicLib.nsh

OutFile "hqinstaller.exe"
Name "HalfQuake Installer"
RequestExecutionLevel admin

Var HalfLifePath

Function .onInit
  ReadRegStr $0 HKCU "SOFTWARE\Valve\Steam" SteamPath
  GetFullPathName $0 "$0"
  StrCmp $0 "" NoSteam CheckHalfLife
  
NoSteam:
  MessageBox MB_OK "You do not seem to have Steam installed. Please do so. Now."
  Quit
  
CheckHalfLife:
  DetailPrint "Found Steam in $0"

  StrCpy $HalfLifePath "$0\steamapps\common\Half-Life"
  IfFileExists $HalfLifePath Done NoHalfLife

NoHalfLife:
  MessageBox MB_OK "You do not seem to have Half-Life installed. Please do so. Now."
  Quit
  
Done:
  DetailPrint "Found Half-Life in: $HalfLifePath"
  Return
  
FunctionEnd

Page components
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

SectionGroup /e "Halfquake"

  Section /o "Halfquake" HQUAKE1
    SetOutPath "$HalfLifePath"
    File /r "hquake"
    # Misuse HQA icon for the lack of a better icon :-/
    CreateShortCut "$DESKTOP\Halfquake.lnk" "$HalfLifePath\hl.exe" "-game hquake" "$HalfLifePath\hquake2\hqa.ico" 0
  SectionEnd

  Section /o "Halfquake: Amen" HQUAKE2
    SetOutPath "$HalfLifePath"
    File /r "hquake2"
    CreateShortCut "$DESKTOP\Halfquake: Amen.lnk" "$HalfLifePath\hl.exe" "-game hquake2" "$HalfLifePath\hquake2\hqa.ico" 0
  SectionEnd

  Section /o "Halfquake: Sunrise" HQUAKE3
    SetOutPath "$HalfLifePath"
    File /r "hquake3"
    CreateShortCut "$DESKTOP\Halfquake: Sunrise.lnk" "$HalfLifePath\hl.exe" "-game hquake3" "$HalfLifePath\hquake3\hqs.ico" 0
  SectionEnd
  
  SectionSetFlags ${HQUAKE1} ${SF_SELECTED}
  SectionSetFlags ${HQUAKE2} ${SF_SELECTED}
  SectionSetFlags ${HQUAKE3} ${SF_SELECTED}
  
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
      MessageBox MB_OK "No HalfQuake MOD selected :-("
      Quit
    ${ENDIF}
  SectionEnd

SectionGroupEnd

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
