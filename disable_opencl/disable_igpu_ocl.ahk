#NoEnv
SetWorkingDir %A_ScriptDir%

If A_PtrSize <> 8
{
  Msgbox, You should not run this script in a x86 interpreter
  Exitapp
}

if (not A_IsAdmin)
{
   try Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

Loop, Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Khronos\OpenCL\Vendors, V
{
  FoundPos := InStr(A_LoopRegName, "IntelOpenCL64.dll")
  if (FoundPos>0)
  {
    RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SOFTWARE\Khronos\OpenCL\Vendors, %A_LoopRegName%, 1
  }
}

Loop, Reg, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors, V
{
  FoundPos := InStr(A_LoopRegName, "IntelOpenCL32.dll")
  if (FoundPos>0)
  {
    RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors, %A_LoopRegName%, 1
  }
}