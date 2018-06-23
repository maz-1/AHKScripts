#NoTrayIcon
#singleinstance,force

ExtractDir:=A_WinDir . "\Temp\patch_bth_icon"
FileCreateDir, %ExtractDir%
SetWorkingDir %ExtractDir%

If (A_Language = "0804")
{
  L_Error:="错误"
  L_Info:="信息"
  L_NotFound:="未找到"
  L_Restore:="已修改，是否恢复？"
  L_RestoreErr:="无法恢复"
  L_Patch:="即将修改蓝牙图标，是否继续？"
  L_DelErr:="无法被删除"
}
Else
{
  L_Error:="Error"
  L_Info:="Info"
  L_NotFound:="not found"
  L_Restore:="already patched, Restore ?"
  L_RestoreErr:="cannot be restored."
  L_Patch:="Bluetooth icon will be changed, Continue ?"
  L_DelErr:="cannot be removed"
}

if (A_IsAdmin)
{
  ThisProcess := DllCall("GetCurrentProcess")
  If DllCall("IsWow64Process", "uint", ThisProcess, "int*", IsWow64Process)
   DllCall("Wow64DisableWow64FsRedirection", Ptr, 0, UInt)
  PriviledgeName:="SeRestorePrivilege"
  DllCall("Advapi32.dll\OpenProcessToken", "Ptr", ThisProcess, "UInt", 32, "PtrP", t)
  VarSetCapacity(ti, 16, 0)
  NumPut(1, ti, 0, "UInt") 
  DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", PriviledgeName, "Int64P", luid)
  NumPut(luid, ti, 4, "Int64")
  NumPut(2, ti, 12, "UInt")
  DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
  DllCall("CloseHandle", "Ptr", t)
  VarSetCapacity(ti, 0)
}
Else
{
  try Run *RunAs "%A_ScriptFullPath%"
  ExitApp
}

FilePath:="C:\Windows\System32\bthprops.cpl"
  

VarSetCapacity( LinkName, 4096, 0 )
searchHandle:=DllCall("Kernel32\FindFirstFileNameW", Ptr, &FilePath, UInt, 0, UIntP, &RtnPathLen, Ptr, &LinkName, Ptr)
If ( searchHandle = -1 )
{
  Msgbox ,, %L_Error%, %FilePath% %L_NotFound%
  Exitapp
}
Else
{
  Result:=DllCall("Kernel32\FindNextFileNameW", Ptr, searchHandle, UIntP, &RtnPathLen, Ptr, &LinkName, Int)
  If ( Result = 0 )
  {
    Msgbox ,4 , %L_Info%, %FilePath% %L_Restore%
    IfMsgBox Yes
    {
      FileDelete, %FilePath%.del
      FileMove, %FilePath%, %FilePath%.del
      If ErrorLevel
        Msgbox ,, %L_Error%, %FilePath% %L_RestoreErr%
      Else
      {
        Runwait, tskill.exe explorer ,,Hide
        FileMove, %FilePath%.bak, %FilePath%
        Sleep 1000
        Runwait, tskill.exe explorer ,,Hide
        FileDelete, %FilePath%.del
      }
    }
    Exitapp
  }
  Else
  {
    Msgbox ,4 , %L_Info%, %L_Patch%
    IfMsgBox No
      Exitapp
    FileDelete, %FilePath%.bak
    if (ErrorLevel && FileExist(FilePath . ".bak"))
    {
      Msgbox ,, %L_Error%, %FilePath%.bak %L_DelErr%
    }
    Else
    {
      FileInstall, bthicon.res, %ExtractDir%\bthicon.res, 1
      FileInstall, ResHacker.exe, %ExtractDir%\ResHacker.exe, 1
      FileMove, %FilePath%, %ExtractDir%\bthprops.cpl.bak
      SplitPath, FilePath, FileName
      Runwait, %ExtractDir%\ResHacker.exe -modify %ExtractDir%\%FileName%.bak`, %ExtractDir%\%FileName%`, bthicon.res `, `, `, 
      FileMove, %ExtractDir%\%FileName%, %FilePath%
      Runwait, icacls %FilePath% /grant Users:(OI)(CI)RX /T,, Hide
      FileMove, %ExtractDir%\%FileName%.bak, %FilePath%.bak
      Runwait, tskill.exe explorer ,,Hide
    }
    FileRemoveDir, %ExtractDir%, 1
  }
}
DllCall( "CloseHandle",  UInt,searchHandle  )
VarSetCapacity( LinkName, 0 )
