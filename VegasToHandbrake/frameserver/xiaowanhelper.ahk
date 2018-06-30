#NoEnv
#NoTrayIcon
#singleinstance off
SetWorkingDir %A_ScriptDir%
EnvGet, UserProfile, UserProfile
InFile=%1%
AppVersion:="0.13965fa_r6"
Envset, __COMPAT_LAYER
Run, xiaowan.exe,,, XiaowanPID
WinWait, ahk_pid %XiaowanPID%
WinGetClass, LogoClass, ahk_pid %XiaowanPID%
RegExMatch(LogoClass, "i)\d\.[0-9a-f]+_r\d+", AppVersion)
AppTitle:="ahk_pid " . XiaowanPID . " ahk_class WindowsForms10.Window.8.app." . AppVersion . "_ad1"
WinWait, %AppTitle%
WinGet, AppMainHwnd, ID, %AppTitle%
If (FileExist(InFile))
{
  SplitPath, InFile,,,, InNameNoExt
  ControlSetText, WindowsForms10.EDIT.app.%AppVersion%_ad16, %InFile%, ahk_id %AppMainHwnd%
  ControlSetText, WindowsForms10.EDIT.app.%AppVersion%_ad15, %UserProfile%\Videos\%InNameNoExt%_maruko.mp4, ahk_id %AppMainHwnd%
}
SetTimer, WaitMarukoClose, 250
Loop
{
  WinGet, MarukoWinList, List, ahk_pid %XiaowanPID%
  If (MarukoWinList > 1)
  {
    Loop, %MarukoWinList%
    {
      If (MarukoWinList%A_Index%=AppMainHwnd)
        Continue
      Else
      {
        ModalWinID:=MarukoWinList%A_Index%
        WinGetTitle, ModalWinTitle, ahk_id %ModalWinID%
        If (RegexMatch(ModalWinTitle, "\(\d+/\d+\)$"))
        {
          ConvertingWinID:=ModalWinID
          Break 2
        }
      }
    }
  }
  Sleep, 250
}
Loop
{
  ControlGet, AbortAvailable, Enabled,, WindowsForms10.BUTTON.app.%AppVersion%_ad12, ahk_id %ConvertingWinID%
  If !AbortAvailable
    Break
  Sleep, 250
}
WinGetTitle, ModalWinTitle, ahk_id %ConvertingWinID%
If RegexMatch(ModalWinTitle, "\((\d+)/\1\)$")
{
  Process, Close, %XiaowanPID%
  Exitapp
}
Else
{
  WinWaitClose, ahk_id %AppMainHwnd%
}
Exitapp


WaitMarukoClose:
If !WinExist("ahk_id " . AppMainHwnd)
Exitapp
Return
