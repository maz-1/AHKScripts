#NoEnv
#SingleInstance off
SetWorkingDir %A_ScriptDir%

WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
WebRequest.SetTimeouts(500, 1000, 5000, 5000)
#include DownloadFile.ahk
#include JSON.ahk

LTitle:="Vegas2HandBrake Installer by maz-1"
LInstalled:="Installed"
LNInstalled:="Not Installed"
LInstalling:="Installing"
LDownloading:="Downloading"
LPrereq:="Prerequisites"
VegasNFound:="Vegas Pro is not found on your system"
LInstV2H:="You are going to install VegasToHandbrake, continue?"
LInstPre:="You need to install some prerequisites, continue?"
LNewVerP1:="New version of"
LNewVerP2:="found, download?"
PreInstErr:="Some Prerequisites failed to install, please try again"
InstDone:="Installation done."
If (A_Language=0804)
{
LTitle:="Vegas2HandBrake安装器 by maz-1"
LInstalled:="已安装"
LNInstalled:="未安装"
LInstalling:="正在安装"
LDownloading:="正在下载"
LPrereq:="依赖软件"
VegasNFound:="没找到Vegas Pro"
LInstV2H:="你即将安装VegasToHandbrake，是否继续?"
LInstPre:="你需要安装一些依赖软件，是否继续?"
LNewVerP1:="发现新版本的"
LNewVerP2:="，是否下载？"
PreInstErr:="一些依赖软件安装失败，请重试"
InstDone:="安装完成"
}

If A_PtrSize <> 8
{
  Msgbox,,%LTitle%, You should not run this script in a x86 interpreter
  Exitapp
}
if (not A_IsAdmin)
{
   try Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

EnvGet, ProgramData, PROGRAMDATA
VegasDir=%ProgramData%\VEGAS Pro

Loop, Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, K
{
  RegRead, DisplayName, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%A_LoopRegName%, DisplayName
  If RegExMatch(DisplayName, "iO)VEGAS Pro ([\d.]+)", Matched)
  {
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%A_LoopRegName%, InstallLocation
    VegasVer:=Matched[1]
    FileRemoveDir, %InstallLocation%\Script Menu\frameserve_scripts, 1
    Break
  }
}

If (!InstallLocation)
{
  Msgbox,,%LTitle% ,%VegasNFound%
  Exitapp
}
Else If !InStr(FileExist(VegasDir), "D")
  FileCreateDir, %VegasDir%


FSInstalled:=false
AVSInstalled:=false
PFMInstalled:=false
HBInstalled:=false
DownloadDir:=A_ScriptDir . "\download"
NetError:=false
FSPath:=""
If CheckStatus()
{
  MsgBox, 4, %LTitle%, %LInstV2H%
  IfMsgBox, Yes
    goto InstallScript
  Else
    Exitapp
}
MsgBox, 4, %LTitle%, %LInstPre%
IfMsgBox, No
  Exitapp
If !InStr(FileExist(DownloadDir), "D")
  FileCreateDir, %DownloadDir%

Gui, Installer:New, +OwnDialogs, %LInstalling%...

Gui, Installer:Add, GroupBox, x16 y16 w250 h147, %LPrereq%

Gui, Installer:Add, Text, x32 y32 w120 h23 +0x200, Frameserver:
Gui, Installer:Add, Text, x160 y32 w84 h23 +0x200 vFSInstalledV, % (FSInstalled ? LInstalled : LNInstalled)

Gui, Installer:Add, Text, x32 y64 w120 h23 +0x200, Avisynth:
Gui, Installer:Add, Text, x160 y64 w83 h23 +0x200 vAVSInstalledV, % (AVSInstalled ? LInstalled : LNInstalled)

Gui, Installer:Add, Text, x32 y96 w120 h23 +0x200, Pismo File Mount:
Gui, Installer:Add, Text, x160 y96 w83 h23 +0x200 vPFMInstalledV, % (PFMInstalled ? LInstalled : LNInstalled)

Gui, Installer:Add, Text, x32 y128 w120 h23 +0x200, HandBrake:
Gui, Installer:Add, Text, x160 y128 w83 h23 +0x200 vHBInstalledV, % (HBInstalled ? LInstalled : LNInstalled)

;Gui, Installer:Add, Button, x180 y168 w80 h31, %LCancel%

Gui, Installer:Show

If !FSInstalled
{
  UrlToFile:="http://www.debugmode.com/download?fssetup_vegas13.exe"
  WebRequest.Open("HEAD", UrlToFile)
  Try
     WebRequest.Send()
  Catch
     NetError:=true
  If (!NetError)
  {
    OLSize := WebRequest.GetResponseHeader("Content-Length")
    If (OLSize <> FileOpen(DownloadDir . "\fssetup_vegas13.exe", "r").Length)
      FileDelete, %DownloadDir%\fssetup_vegas13.exe
    If (!FileExist(DownloadDir . "\fssetup_vegas13.exe"))
    {
      GuiControl, Text, FSInstalledV, %LDownloading%...
      DownloadStat:=DownloadFile(UrlToFile, DownloadDir . "\fssetup_vegas13.exe")
      If DownloadStat
        goto SkipFSInst
    }
  }
  Else
    goto SkipFSInst
  GuiControl, Text, FSInstalledV, %LInstalling%
    SetControlDelay -1
    Run, `"%DownloadDir%\fssetup_vegas13.exe`",,, FSInstPID
    FSInstTitle:="ahk_pid " . FSInstPID . " ahk_class #32770"
    FSInstPopup:="DebugMode FrameServer Setup ahk_class #32770 ahk_pid " . FSInstPID
    WinWait, %FSInstTitle%
    ControlClick, Button2, %FSInstTitle%
    Sleep 200
    ControlClick, Button2, %FSInstTitle%
    Sleep 200
    ControlGetText, FSPath, Edit1, %FSInstTitle%
    ControlClick, Button2, %FSInstTitle%
    Sleep 200
    ControlSetText , Edit1, %FSPath%, %FSInstTitle%
    FileCreateDir, %FSPath%
    ControlClick, Button2, %FSInstTitle%
    Sleep 200
    WinWait, %FSInstPopup%
    Sleep 200
    ControlClick, Button1, %FSInstPopup%
    WinWaitClose, %FSInstTitle%
    SkipFSInst:
    CheckStatus()
    If FSInstalled
    {
      GuiControl, Text, FSInstalledV, %LInstalled%
    }
    Else
      GuiControl, Text, FSInstalledV, %LNInstalled%
}

If !AVSInstalled
{
  AVSArr:=""
  Loop, Files, %DownloadDir%\AviSynthPlus-MT-r*-with-vc_redist.exe
  {
    If RegExMatch(A_LoopFileName, "iO)AviSynthPlus-MT-r(\d+)-with-vc_redist\.exe", Matched)
      AVSArr := AVSArr . ( !AVSArr ? Matched[1] : "," . Matched[1])
  }
  If (AVSArr)
  {
    Sort AVSArr, N R D,
    LocalVersion:=StrSplit(AVSArr , ",")[1]
  }
  Else
  {
    LocalVersion:=0
  }
  AVSOLArr:=""
  WebRequest.Open("GET", "https://api.github.com/repos/pinterf/AviSynthPlus/releases/latest")
  Try
    WebRequest.Send()
  Catch
    goto SkipAVSOLCheck
  AVSJSON := JSON.Load(WebRequest.ResponseText)
  OnlineVersion:=SubStr(AVSJSON.tag_name, 2)
  If (OnlineVersion = LocalVersion and AVSJSON.assets[1].size <> FileOpen(DownloadDir . "\AviSynthPlus-MT-r" . LocalVersion . "-with-vc_redist.exe", "r").Length)
    FileCorrupt := true
  Else
    FileCorrupt := false
  If (OnlineVersion > LocalVersion)
  {
    If (LocalVersion<>0)
    {
      MsgBox, 4, %LTitle%, %LNewVerP1% AvisynthPlus %LNewVerP2%, 10
      IfMsgBox, No
        goto SkipAVSOLCheck
    }
    GuiControl, Text, AVSInstalledV, %LDownloading%...
    DownloadStat:=DownloadFile(AVSJSON.assets[1].browser_download_url, DownloadDir . "\AviSynthPlus-MT-r" . OnlineVersion . "-with-vc_redist.exe", True, True, AVSJSON.assets[1].size)
    If (!DownloadStat and FileExist(DownloadDir . "\AviSynthPlus-MT-r" . OnlineVersion . "-with-vc_redist.exe"))
    {
      FileDelete, %DownloadDir%\AviSynthPlus-MT-r%LocalVersion%-with-vc_redist.exe
      LocalVersion:=OnlineVersion
    }
  }
  Else If (FileCorrupt)
  {
    FileDelete, %DownloadDir%\AviSynthPlus-MT-r%OnlineVersion%-with-vc_redist.exe
    GuiControl, Text, AVSInstalledV, %LDownloading%...
    DownloadFile(AVSJSON.assets[1].browser_download_url, DownloadDir . "\AviSynthPlus-MT-r" . OnlineVersion . "-with-vc_redist.exe", True, True, AVSJSON.assets[1].size)
  }
  SkipAVSOLCheck:
  GuiControl, Text, AVSInstalledV, %LInstalling%
  If (FileExist(DownloadDir . "\AviSynthPlus-MT-r" . LocalVersion . "-with-vc_redist.exe"))
  {
    Run, `"%DownloadDir%\AviSynthPlus-MT-r%LocalVersion%-with-vc_redist.exe`" /VERYSILENT /NORESTART,,, AVSInstPID
    InstallingAnim(AVSInstPID, "AVSInstalledV")
  }
  CheckStatus()
  If AVSInstalled
    GuiControl, Text, AVSInstalledV, %LInstalled%
  Else
    GuiControl, Text, AVSInstalledV, %LNInstalled%
}

If !PFMInstalled
{
  PFMArr:=""
  Loop, Files, %DownloadDir%\pfm-*-testing-win.exe
  {
    If RegExMatch(A_LoopFileName, "iO)pfm-(\d+)-testing-win\.exe", Matched)
      PFMArr := PFMArr . ( !PFMArr ? Matched[1] : "," . Matched[1])
  }
  If (PFMArr)
  {
    Sort PFMArr, N R D,
    LocalVersion:=StrSplit(PFMArr , ",")[1]
  }
  Else
  {
    LocalVersion:=0
  }
  PFMOLArr:=""
  WebRequest.Open("GET", "http://pismotec.com/download/")
  Try
    WebRequest.Send()
  Catch
    goto SkipPFMOLCheck
  RegExMatch(WebRequest.ResponseText, "iO)pfm-(\d+)-testing-win\.exe", Matched)
  OnlineVersion:=Matched[1]
  OnlineURL:="http://pismotec.com/download/pfm-" . OnlineVersion . "-testing-win.exe"
  OnlineSize:=GetOnlineSize(OnlineURL)
  If (OnlineVersion = LocalVersion and OnlineSize <> FileOpen(DownloadDir . "\pfm-" . LocalVersion . "-testing-win.exe", "r").Length)
    FileCorrupt := true
  Else
    FileCorrupt := false
  If (OnlineVersion > LocalVersion)
  {
    If (LocalVersion<>0)
    {
      MsgBox, 4, %LTitle%, %LNewVerP1% Pismo File Mount %LNewVerP2%, 10
      IfMsgBox, No
       goto SkipPFMOLCheck
    }
    GuiControl, Text, PFMInstalledV, %LDownloading%...
    DownloadStat:=DownloadFile(OnlineURL, DownloadDir . "\pfm-" . OnlineVersion . "-testing-win.exe")
    If (!DownloadStat and FileExist(DownloadDir . "\pfm-" . OnlineVersion . "-testing-win.exe"))
    {
      FileDelete, %DownloadDir%\pfm-%LocalVersion%-testing-win.exe
      LocalVersion:=OnlineVersion
    }
  }
  Else If (FileCorrupt)
  {
    FileDelete, %DownloadDir%\pfm-%OnlineVersion%-testing-win.exe
    GuiControl, Text, PFMInstalledV, %LDownloading%...
    DownloadFile(OnlineURL, DownloadDir . "\pfm-" . OnlineVersion . "-testing-win.exe")
  }
  SkipPFMOLCheck:
  GuiControl, Text, PFMInstalledV, %LInstalling%
  If (FileExist(DownloadDir . "\pfm-" . LocalVersion . "-testing-win.exe"))
  {
    Run, `"%DownloadDir%\pfm-%LocalVersion%-testing-win.exe`" install,, Hide, PFMInstPID
    InstallingAnim(PFMInstPID, "PFMInstalledV")
  }
  CheckStatus()
  If PFMInstalled
    GuiControl, Text, PFMInstalledV, %LInstalled%
  Else
    GuiControl, Text, PFMInstalledV, %LNInstalled%
}

If !HBInstalled
{
  HBArr:=""
  Loop, Files, %DownloadDir%\HandBrake-*-x86_64-Win_GUI.exe
  {
    If RegExMatch(A_LoopFileName, "iO)HandBrake-([\d.]+)-x86_64-Win_GUI\.exe", Matched)
      HBArr := HBArr . ( !HBArr ? Matched[1] : "," . Matched[1])
  }
  If (HBArr)
  {
    Sort HBArr, N R D,
    LocalVersion:=StrSplit(HBArr , ",")[1]
  }
  Else
  {
    LocalVersion:=0
  }
  HBOLArr:=""
  WebRequest.Open("GET", "https://api.github.com/repos/HandBrake/HandBrake/releases/latest")
  Try
    WebRequest.Send()
  Catch
    goto SkipHBOLCheck
  HBJSON := JSON.Load(WebRequest.ResponseText)
  OnlineVersion:=HBJSON.tag_name
  OnlineURL:="https://download.handbrake.fr/releases/" . OnlineVersion . "/HandBrake-" . OnlineVersion . "-x86_64-Win_GUI.exe"
  OnlineSize:=GetOnlineSize(OnlineURL)
  If (OnlineVersion = LocalVersion and OnlineSize <> FileOpen(DownloadDir . "\HandBrake-" . LocalVersion . "-x86_64-Win_GUI.exe", "r").Length)
    FileCorrupt := true
  Else
    FileCorrupt := false
  If (OnlineVersion > LocalVersion)
  {
    If (LocalVersion<>0)
    {
      MsgBox, 4, %LTitle%, %LNewVerP1% HandBrake %LNewVerP2%, 10
      IfMsgBox, No
       goto SkipHBOLCheck
    }
    GuiControl, Text, HBInstalledV, %LDownloading%...
    DownloadStat:=DownloadFile(OnlineURL, DownloadDir . "\HandBrake-" . OnlineVersion . "-x86_64-Win_GUI.exe")
    If (!DownloadStat and FileExist(DownloadDir . "\HandBrake-" . OnlineVersion . "-x86_64-Win_GUI.exe"))
    {
      FileDelete, %DownloadDir%\HandBrake-%LocalVersion%-x86_64-Win_GUI.exe
      LocalVersion:=OnlineVersion
    }
  }
  Else If (FileCorrupt)
  {
    FileDelete, %DownloadDir%HandBrake-%OnlineVersion%-x86_64-Win_GUI.exe
    GuiControl, Text, HBInstalledV, %LDownloading%...
    DownloadFile(OnlineURL, DownloadDir . "\HandBrake-" . OnlineVersion . "-x86_64-Win_GUI.exe")
  }
  SkipHBOLCheck:
  GuiControl, Text, HBInstalledV, %LInstalling%
  If (FileExist(DownloadDir . "\HandBrake-" . LocalVersion . "-x86_64-Win_GUI.exe"))
  {
    Run, `"%DownloadDir%\HandBrake-%LocalVersion%-x86_64-Win_GUI.exe`" /S,, Hide, HBInstPID
    InstallingAnim(HBInstPID, "HBInstalledV")
  }
  CheckStatus()
  If HBInstalled
    GuiControl, Text, HBInstalledV, %LInstalled%
  Else
    GuiControl, Text, HBInstalledV, %LNInstalled%
}

If !CheckStatus()
{
  Msgbox,, %LTitle%, %PreInstErr%
  Exitapp
}
Gui Hide
InstallScript:
;FileCreateDir, C:\Program Files\VEGAS\frameserver
;FileInstall, frameserver\vegas2handbrake.ahk, C:\Program Files\VEGAS\frameserver\vegas2handbrake.ahk, 1
;FileInstall, frameserver\vegas2handbrake.exe, C:\Program Files\VEGAS\frameserver\vegas2handbrake.exe, 1
;FileInstall, frameserver\AVFS.exe, C:\Program Files\VEGAS\frameserver\AVFS.exe, 1
RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Sony Creative Software\Vegas Pro\frameserver, ScriptDir, C:\Program Files\VEGAS\frameserver
Config_Path:=InstallLocation . "\Release-x64.fio2007-config"
if FileExist(Config_Path)
{
        IniWrite, %FSPath%\dfscVegasV264Out.dll, %Config_Path%, FileIO Plug-Ins, frameserver
        ;FileRemoveDir, %VegasDir%\Script Depends\, 1
        FileCreateDir, %VegasDir%\Script Depends\
        FileInstall, Script Depends\AVFS.exe, %VegasDir%\Script Depends\AVFS.exe, 1
        FileInstall, Script Depends\AutoHotkey.dll, %VegasDir%\Script Depends\AutoHotkey.dll, 1
        FileRemoveDir, %VegasDir%\Script Menu\frameserve_scripts\, 1
        FileCreateDir, %VegasDir%\Script Menu\frameserve_scripts\
        FileInstall, frameserve_scripts\Preferences.cs, %VegasDir%\Script Menu\frameserve_scripts\Preferences.cs, 1
        FileInstall, frameserve_scripts\Send2HandBrake.cs, %VegasDir%\Script Menu\frameserve_scripts\Send2HandBrake.cs, 1
        FileInstall, frameserve_scripts\Preferences.cs.png, %VegasDir%\Script Menu\frameserve_scripts\Preferences.cs.png, 1
        FileInstall, frameserve_scripts\Send2HandBrake.cs.png, %VegasDir%\Script Menu\frameserve_scripts\Send2HandBrake.cs.png, 1
        If (VegasVer < 14.0)
        {
          ModifyScriptForLegacy(VegasDir . "\Script Menu\frameserve_scripts\Preferences.cs")
          ModifyScriptForLegacy(VegasDir . "\Script Menu\frameserve_scripts\Send2HandBrake.cs")
        }
}
MsgBox,, %LTitle%, %InstDone%, 5
Exitapp

GuiEscape:
GuiClose:
ExitApp

ModifyScriptForLegacy(File)
{
  Loop, Read, %File%, %File%.tmp
  {
    line := a_LoopReadLine
    StringReplace, line, line, % "//using Sony.Vegas;", % "using Sony.Vegas;"
    StringReplace, line, line, % "using ScriptPortal.Vegas;", % "//using ScriptPortal.Vegas;"
    FileAppend, %line%`r`n
  }
  FileMove, %File%.tmp, %File%, 1
}

CheckStatus()
{
  Global
  RegRead, FSUninst ,HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DebugMode FrameServer, UninstallString
  If FSUninst
  {
    FSInstalled:=true
    FSUninst:=SubStr(FSUninst, 2, StrLen(FSUninst)-2)
    SplitPath, FSUninst,, FSPath
  }
  If FileExist("C:\Windows\SysWOW64\AviSynth.dll")
    AVSInstalled:=true
  If FileExist("C:\Windows\PismoFileMount\pfm.exe")
    PFMInstalled:=true
  RegRead, HBEXE, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\HandBrake
  if FileExist(HBEXE)
    HBInstalled:=true
  Return (FSInstalled and AVSInstalled and PFMInstalled and HBInstalled)
}

InstallingAnim(InstPID, ControlVar)
{
  Global LInstalling
  Dots:=""
  Loop
  {
    Process, Exist, %InstPID%
    If !ErrorLevel
      Break
    If (Dots="")
      Dots:="."
    Else If (Dots=".")
      Dots:=".."
    Else If (Dots="..")
      Dots:="..."
    Else If (Dots="...")
      Dots:=""
    GuiControl, Text, %ControlVar%, %LInstalling%%Dots%
    Sleep 300
  }
}