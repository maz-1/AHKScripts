#NoEnv
#NoTrayIcon
#SingleInstance off

LPrefTitle:="send2handbrake preferences (maz_1@foxmail.com)"
LEncPathGrp:="Encoder Path"
LAutodetect:="Auto-detect Handbrake path"
LEncPathTip:="Specify encoder path:"
LEncManual:="Let me use encoder manually"
LTempDir:="Temporary file directory"
LAddBuf:="Add 1-second buffer before rendering"
LRendAud:="Render Audio"
LUnmount:="Unmount"
LOK:="OK"
LCancel:="Cancel"
LTempSel:="Choose temporary file directory"
LEncSel:="Choose encoder"
LRendLoop:="Render loop region when exists"
If (A_Language="0804")
{
LPrefTitle:="send2handbrake偏好设置 (maz_1@foxmail.com)"
LEncPathGrp:="编码器路径"
LAutodetect:="自动检测Handbrake路径"
LEncPathTip:="指定编码器路径:"
LEncManual:="手动打开编码器"
LTempDir:="临时文件目录"
LAddBuf:="渲染前添加一秒长的缓冲"
LRendAud:="渲染音频"
LUnmount:="卸载"
LOK:="好"
LCancel:="取消"
LTempSel:="选择临时文件路径"
LEncSel:="选择编码器"
LRendLoop:="渲染循环区域（如果存在）"
}

EnvGet, Temp, Temp
RegKey:="HKEY_CURRENT_USER\Software\Sony Creative Software\Vegas Pro\frameserver"
RegRead, AutoDetectHandBrake, %RegKey%, AutoDetectHandBrake
RegRead, EncoderPath, %RegKey%, EncoderPath
RegRead, AddBuffer, %RegKey%, AddBuffer
RegRead, RenderAudio, %RegKey%, RenderAudio
RegRead, TempDir, %RegKey%, TempDir
RegRead, RenderLoopRegion, %RegKey%, RenderLoopRegion

WinGet, VegasHwnd, ID, % "ahk_class Vegas.Class.Frame ahk_pid " . DllCall("GetCurrentProcessId")

Gui, GuiConfig:New, +Owner%VegasHwnd% ToolWindow, % LPrefTitle
Gui, GuiConfig:Add, GroupBox, w320 h120, % LEncPathGrp
Gui, GuiConfig:Add, Radio, xp+10 yp+20 vEncoderChoice checked gGuiDisableEdit h20 hwndhEncRadio1, % LAutodetect
Gui, GuiConfig:Add, Radio, gGuiEnableEdit h20 hwndhEncRadio2, % LEncPathTip
Gui, GuiConfig:Add, Radio, yp+50 gGuiDisableEdit h20 hwndhEncRadio3, % LEncManual
Gui, GuiConfig:Add, Edit, r1 yp-25 w270 h20 vEncPath hwndHEncPath
Gui, GuiConfig:Add, Button, vPathBtn gGuiSelectPath xp+270 h20 , ...
Gui, GuiConfig:Add, GroupBox, w320 h40 x10 y+30, % LTempDir
Gui, GuiConfig:Add, Edit, r1 x20 yp+15 w248 h20 vTmpDir hwndhTmpDir
Gui, GuiConfig:Add, Button, xp+248 h20 gGuiSelectTmpPath, ...
Gui, GuiConfig:Add, Button, xp+24 h20 w24 gGuiResetTempDir, R
Gui, GuiConfig:Add, Checkbox, x10 y+10 h20 vAddBuf hwndhAddBuf, % LAddBuf
Gui, GuiConfig:Add, Checkbox, x10 y+5 h20 vRenderAud hwndhRenderAud, % LRendAud
Gui, GuiConfig:Add, Checkbox, x10 y+5 h20 vRenderLoop hwndhRenderLoop, % LRendLoop
Gui, GuiConfig:Add, Button, vBtnUnmount gGuiUnmount x10 yp+30 w80, % LUnmount
Gui, GuiConfig:Add, Button, vBtnOK gGuiOK xp+150 yp+0 w80, % LOK
Gui, GuiConfig:Add, Button, gGuiCancel xp+90 yp+0 w80, % LCancel
If (AutoDetectHandBrake<>2)
{
  GuiControl, GuiConfig:Disable, EncPath
  GuiControl, GuiConfig:Disable, PathBtn
}
hEncRadio:=hEncRadio%AutoDetectHandBrake%
GuiControl, , %hEncRadio%, 1

if FileExist(EncoderPath)
  GuiControl, GuiConfig:Text, EncPath, % EncoderPath
If (AddBuffer<>0 or AddBuffer="")
  GuiControl, , %hAddBuf%, 1
If (RenderAudio<>0 or RenderAudio="")
  GuiControl, , %hRenderAud%, 1
If (RenderLoopRegion<>0 or RenderLoopRegion="")
  GuiControl, , %hRenderLoop%, 1
If (TempDir)
  GuiControl, , %hTmpDir%, %TempDir%
Gui, GuiConfig:Show
WinSet, Disable ,, ahk_id %VegasHwnd%
Return
GuiResetTempDir:
GuiControl, GuiConfig:Text, TmpDir, %Temp%\frameserver
Return
GuiSelectTmpPath:
Gui, GuiConfig:+OwnDialogs
FileSelectFolder, TmpDirFromDiag, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, , % LTempSel
if ! ErrorLevel
  GuiControl, , % hTmpDir, % TmpDirFromDiag
Return
GuiCancel:
GuiConfigGuiClose:
WinSet, Enable ,, ahk_id %VegasHwnd%
ExitApp
GuiUnmount:
unmount()
Return
GuiOK:
WinSet, Enable ,, ahk_id %VegasHwnd%
Gui, GuiConfig:Submit
RegWrite, REG_DWORD, %RegKey%, AutoDetectHandBrake, %EncoderChoice%
RegWrite, REG_SZ, %RegKey%, EncoderPath, %EncPath%
RegWrite, REG_DWORD, %RegKey%, AddBuffer, %AddBuf%
RegWrite, REG_DWORD, %RegKey%, RenderAudio, %RenderAud%
RegWrite, REG_DWORD, %RegKey%, RenderLoopRegion, %RenderLoop%
RegWrite, REG_SZ, %RegKey%, TempDir, %TmpDir%
Exitapp
GuiSelectPath:
Gui, GuiConfig:+OwnDialogs
FileSelectFile, EncoderPathFromDiag, , , %LEncSel%, *.exe
if ! ErrorLevel
  GuiControl, , % HEncPath, % EncoderPathFromDiag
Return
GuiDisableEdit:
GuiControl, GuiConfig:Disable, EncPath
GuiControl, GuiConfig:Disable, PathBtn
Return
GuiEnableEdit:
GuiControl, GuiConfig:Enable, EncPath
GuiControl, GuiConfig:Enable, PathBtn
Return

unmount()
{
  Global
  ;RunWait, pfm unmount C:\Volumes\%VegasPID%.avs,, Hide
  ;Sleep, 1000
  ;RunWait, pfm unregister %A_ScriptDir%\avfs.dll,, Hide
  Process, Close, AVFS.exe
  FileDelete, %TempFileDir%\*.avs
  FileDelete, %TempFileDir%\*.avi
}