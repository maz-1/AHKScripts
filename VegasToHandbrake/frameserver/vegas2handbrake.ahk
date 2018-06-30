#NoEnv
#SingleInstance off
DetectHiddenText, On
DetectHiddenWindows, On
SetWinDelay, 100

Pause, On

;WorkingDir=%2%
;If WorkingDir
;SetWorkingDir, %WorkingDir%

LWaitingTitle:="Waiting for your operations..."
LStop:="Stop"
LCopyPath:="Copy path"
LOpenFolder:="Open Folder"
If (A_Language="0804")
{
LWaitingTitle:="等待操作..."
LStop:="停止"
LCopyPath:="复制路径"
LOpenFolder:="打开文件夹"
}

VegasPID:=DllCall("GetCurrentProcessId")
VegasPath:=GetProcessName(VegasPID)
;SplitPath, VegasPath,, VegasDir
SetWorkingDir, %VegasDir%
Menu, Tray, Tip, Send to HandBrake
Menu, Tray, Icon, %VegasPath%, 1, 1
EnvGet, AppData, AppData
EnvGet, Temp, Temp
;RegKey:="HKEY_CURRENT_USER\Software\Sony Creative Software\Vegas Pro\frameserver"
RegRead, AutoDetectHandBrake, %RegKey%, AutoDetectHandBrake
RegRead, EncoderPath, %RegKey%, EncoderPath
;RegRead, AddBuffer, %RegKey%, AddBuffer
RegRead, RenderAudio, %RegKey%, RenderAudio
;RegRead, TempDir, %RegKey%, TempDir
;TempFileDir=%1%
;If !TempFileDir
;  TempFileDir:=TempDir
;If !InStr(FileExist(TempFileDir), "D")
;  TempFileDir:=Temp . "\frameserver"
AviFile:=TempFileDir . "\" . VegasPID . ".avi"
AvsFile:=TempFileDir . "\" . VegasPID . ".avs"
FSetupTitle:="FrameServer - (Setup) ahk_class #32770" . " ahk_pid " . VegasPID
FServeTitle:="FrameServer - (Status) ahk_class #32770" . " ahk_pid " . VegasPID
RenderingTitle:="0% ahk_class Vegas.Class.Frame" . " ahk_pid " . VegasPID
RenderingCancelTitle:="ahk_class #32770" . " ahk_pid " . VegasPID
;WritingAviTitle:="Writing signpost AVI... ahk_class #32770" . " ahk_pid " . VegasPID
;RenderingCancelText:="Render process not completed"
WaitingText:="Waiting for your operations..."
WaitingTitle=Vegas2HandBrake ahk_class AutoHotkeyGUI ahk_pid %VegasPID%
SetControlDelay -1
FServeText:="0% realtime (0.00 fr"
AvsContent:="OpenDMLSource(""" . AviFile . """)"
If (RenderAudio=0)
 AvsContent:=AvsContent . ".KillAudio"
AvsContent:=AvsContent . "`r`n"
If (AddBuffer<>0)
 AvsContent:=AvsContent . "Trim(0, FrameCount-1-Floor(FrameRate))`r`n"
AvsContent:=AvsContent . "ConvertToYUY2(matrix=""rec709"")`r`n"
AvsContent:=AvsContent . "ColorYUV(levels=""TV->PC"")"

If (AutoDetectHandBrake=1 or AutoDetectHandBrake="")
{
  RegRead, ConverterEXE, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\HandBrake
}
Else
{
  ConverterEXE:=EncoderPath
}
if !FileExist(ConverterEXE)
  ConverterEXE:="C:\Program Files\HandBrake\HandBrake.exe"
SplitPath, ConverterEXE ,, ConverterFolder
WinWaitActivate(FSetupTitle)
ControlClick, Button1, %FSetupTitle%
ControlClick, Button4, %FSetupTitle%
If (RenderAudio=0)
  Control, UnCheck,, Button6, %FSetupTitle%
Else
  Control, Check,, Button6, %FSetupTitle%
Sleep, 100
ControlClick, Button8, %FSetupTitle%
Loop
{
  DetectConverting()
  If (WinExist(FServeTitle) and FileExist(AviFile))
    Break
  Sleep, 1000
}
FileDelete, %AvsFile%
FileAppend, %AvsContent%, %AvsFile%
;RunWait, pfm register %A_ScriptDir%\avfs.dll,, Hide
;Sleep, 1000
;RunWait, pfm mount `"%AvsFile%`",, Hide
Run, %A_WorkingDir%\Script Depends\AVFS.exe `"%AvsFile%`",, Hide, AVFSPid
Sleep, 1000
Loop
{
  DetectConverting()
  FileGetSize, AviSize, C:\Volumes\%VegasPID%.avs\%VegasPID%.avi
  If (AviSize > 160000)
    Break
  Sleep, 2000
}
AviRaw=C:\Volumes\%VegasPID%.avs\%VegasPID%.avi
Envset, __COMPAT_LAYER
If (AutoDetectHandBrake=3)
{
  SetTimer, Terminate, 500
  SetTimer, CreateWaitingGui, -1
  WinWait, %WaitingTitle%
  WinWaitClose, %WaitingTitle%
}
Else
  RunWait, `"%ConverterEXE%`" `"%AviRaw%`", %ConverterFolder%
Sleep, 500
WinWaitActivate(FServeTitle, FServeText, 2)
ControlClick, Button1, %FServeTitle%
Sleep, 500
unmount()
Sleep, 500
if WinExist(RenderingTitle)
{
  ControlClick, Button4, %RenderingTitle%
  ;Sleep, 200
  ;WinWaitActivate(RenderingCancelTitle, RenderingCancelText, 5)
  ;ControlClick, Button1, %RenderingCancelTitle%, %RenderingCancelText%
}
Exitapp

WinWaitActivate(Wintitle, Wintext:="", timeout:=0)
{
  If (timeout<>0)
    WinWait, %Wintitle%, %Wintext%, %timeout%
  Else
    WinWait, %Wintitle%, %Wintext%
  IfWinNotActive, %Wintitle%, %Wintext%
    WinActivate, %Wintitle%, %Wintext%
}
DetectConverting()
{
  Global
  IfWinNotExist, %RenderingTitle%
  {
    unmount()
    Exitapp
  }
}
unmount()
{
  Global
  ;RunWait, pfm unmount C:\Volumes\%VegasPID%.avs,, Hide
  ;Sleep, 1000
  ;RunWait, pfm unregister %A_ScriptDir%\avfs.dll,, Hide
  If (AVFSPid)
  {
    Process, Close, %AVFSPid%
    Loop
    {
      FileDelete, %AviFile%
      If !ErrorLevel
        Break
      Else
        Sleep, 500
    }
    FileDelete, %AvsFile%
  }
  Else
  {
    Process, Close, AVFS.exe
    FileDelete, %TempFileDir%\*.avs
    FileDelete, %TempFileDir%\*.avi
  }
}

GetProcessName(ProcessID)
{
    if (hProcess := DllCall("OpenProcess", "uint", 0x0410, "int", 0, "uint", ProcessID, "ptr")) {
        size := VarSetCapacity(buf, 0x0104 << 1, 0)
        if (DllCall("psapi\GetModuleFileNameEx", "ptr", hProcess, "ptr", 0, "ptr", &buf, "uint", size))
            return StrGet(&buf), DllCall("CloseHandle", "ptr", hProcess)
        DllCall("CloseHandle", "ptr", hProcess)
    }
    return false
}

Terminate:
IfWinNotExist, %RenderingTitle%
{
  unmount()
  Exitapp
}
Return

CreateWaitingGui:
Gui, Waiting:New, +ToolWindow +AlwaysOnTop +hwndhWaiting
Gui, Waiting:Add, Button, x28 y77 w88 h27 gOpenFolder, % LOpenFolder
Gui, Waiting:Add, Button, x125 y77 w88 h27 gCopyPath, % LCopyPath
Gui, Waiting:Add, Button, x221 y77 w88 h27 gWaitingGuiClose, % LStop
Gui, Waiting:Add, Text, x13 y26 w282 h17, % LWaitingTitle
Gui, Waiting:Show, w330 h117, Vegas2HandBrake
WinWait, ahk_id %hWaiting%
WinActivate, ahk_id %hWaiting%
Return
WaitingGuiEscape:
WaitingGuiClose:
Gui, Waiting:Destroy
Return
OpenFolder:
Run %COMSPEC% /c explorer.exe /select`, "%AviRaw%",, Hide
Return
CopyPath:
ClipBoard:=AviRaw
Return