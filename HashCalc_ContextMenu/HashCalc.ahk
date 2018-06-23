#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoTrayIcon

If (A_Language=0804)
{
L_Possession:="的"
L_Value:="值"
L_File_s:="文件的"
L_ValueIs:="值为："
L_ChooseOp:="`n`n选择你要执行的操作"
L_Usage:="用法"
L_Tip:="可以将MD5替换为MD2、MD4、SHA、SHA256、SHA384、SHA512或CRC32"
L_Tip_install:="点击确定安装或卸载该程序"
L_Info:="信息"
L_ErrorTip:="请手动删除"
L_Install:="安装"
L_Uninstall:="卸载"
L_ClickConfirm:="点击确定"
L_GetHash:="获取散列"
L_Get:="获取"
L_Tooltip:="正在计算"
L_Exit:="退出"
L_Copy:="复制(&C)"
L_Cancel:="取消(&A)"
L_Save:="保存(&S)"
L_Verify:="校验(&V)"
L_Gen:="生成"
L_CantVerify:="无法校验"
L_FileOK:="文件未损坏"
L_FileBad:="校验值不符，下列文件可能已损坏："
}
Else
{
L_Possession:="'s "
L_Value:=" Value"
L_File_s:="File's "
L_ValueIs:=" Value is : "
L_ChooseOp:="`n`nChoose a operation you want"
L_Usage:="Usage"
L_Tip:="You can substitute MD5 with MD2, MD4, SHA1, SHA256, SHA384, SHA512 or CRC32"
L_Tip_install:="Click OK to install or uninstall the program"
L_Info:="Info"
L_ErrorTip:="Please manually delete "
L_Install:="Install"
L_Uninstall:="Uninstall"
L_ClickConfirm:="Click OK to "
L_GetHash:="Get Hash"
L_Get:="Get "
L_Tooltip:="Calculating "
L_Exit:="Exit"
L_Copy:="&Copy"
L_Cancel:="C&ancel"
L_Save:="&Save"
L_Verify:="&Verify"
L_Gen:="Create "
L_CantVerify:="Cannot Verify"
L_FileOK:="File is OK"
L_FileBad:="Value mismatch, following file is possibly corrupted:"
}

Program:="HashCalc.exe"
ExtraBin:="C:\Windows\ExtraBin\"
ProgramFullPath:=ExtraBin . Program

HashType=%1%
FpathOrig=%2%

;If (A_PtrSize <> 8 or !A_IsCompiled)
;{
;  Msgbox, You should compile this script as x64 exe
;  Exitapp
;}

If (HashType<>"")
{
  If (FpathOrig="")
  {
    FpathOrig:=HashType
    HashType:="MD5"
  }
}
Else
{
  Msgbox, 0, %L_Usage%, %A_ScriptName% MD5 C:\Path\to\file`n`n%L_Tip%
  If (A_IsCompiled)
  {
    if (!A_IsAdmin)
    {
      Msgbox, 1, %L_Install%, %L_Tip_install%
      IfMsgBox OK
      {
        ;FileCopy, %A_ScriptFullPath%, %A_Temp%/%Program%
        ;try Run *RunAs "%A_Temp%/%Program%"
        try Run *RunAs "%A_ScriptFullPath%"
      }
      ExitApp
    }
    Else
    {
      IfExist, %ProgramFullPath%
      {
        Msgbox, 1, %L_Uninstall%, %L_ClickConfirm%%L_Uninstall%
        IfMsgBox OK
        {
          RegDelete, HKEY_CLASSES_ROOT\*\shell\Hash
          RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD2
          RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD4
          RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD5
          RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA1
          RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA384
          RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA512
          RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.CRC32
          FileDelete, %ProgramFullPath%
          If ErrorLevel
            Msgbox, 1, %L_Info%, %L_ErrorTip%%Program%
        }
        Exitapp
      }
      Else
      {
        Msgbox, 1, %L_Install%, %L_ClickConfirm%%L_Install%
        IfMsgBox OK
        {
          FileCreateDir, %ExtraBin%
          FileCopy, %A_ScriptFullPath%, %ProgramFullPath%
          RegWrite, REG_SZ, HKEY_CLASSES_ROOT\*\shell\Hash, MUIVerb, %L_GetHash%
          RegWrite, REG_SZ, HKEY_CLASSES_ROOT\*\shell\Hash, Icon, %ProgramFullPath%,1
          RegWrite, REG_SZ, HKEY_CLASSES_ROOT\*\shell\Hash, SubCommands, Hash.CRC32;Hash.MD2;Hash.MD4;Hash.MD5;Hash.SHA1;Hash.SHA256;Hash.SHA384;Hash.SHA512
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD2,, %L_Get%M&D2
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD2\command,, %ProgramFullPath% MD2 "`%1"
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD4,, %L_Get%MD&4
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD4\command,, %ProgramFullPath% MD4 "`%1"
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD5,, %L_Get%&MD5
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.MD5\command,, %ProgramFullPath% MD5 "`%1"
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA1,, %L_Get%SHA&1
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA1\command,, %ProgramFullPath% SHA1 "`%1"
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA256,, %L_Get%SHA&256
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA256\command,, %ProgramFullPath% SHA256 "`%1"
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA384,, %L_Get%SHA&384
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA384\command,, %ProgramFullPath% SHA384 "`%1"
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA512,, %L_Get%SHA&512
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.SHA512\command,, %ProgramFullPath% SHA512 "`%1"
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.CRC32,, %L_Get%&CRC32
          RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Hash.CRC32\command,, %ProgramFullPath% CRC32 "`%1"
        }
      }
    }
  }
  Exitapp
}

#Include Crypt.ahk
#Include CryptConst.ahk
#Include CryptFoos.ahk

CurrentPID:=DllCall("GetCurrentProcessId")
Loop, %FpathOrig%
    Fpath:=A_LoopFileLongPath
SplitPath, Fpath, Fname, FDir,,FnameNoExt
Menu, Tray, Icon
Menu, Tray, Tip , %L_Tooltip%%HashType%
Menu, Tray, NoStandard
Menu, Tray, add, %L_Exit%, Exit
FileHash:=File%HashType%(Fpath)
Menu, Tray, NoIcon
HashFilePath := FDir . "\" . FnameNoExt . "." . GetHashFileExt(HashType)
SetTimer, ChangeButtonNames, 50
If (GetHashFileExt(HashType) = False)
{
  Msgbox,4, `"%Fname%`"%L_Possession%%HashType%%L_Value%, %  L_File_s . HashType . L_ValueIs . FileHash . L_ChooseOp
}
Else
{
  Msgbox,3, `"%Fname%`"%L_Possession%%HashType%%L_Value%, %  L_File_s . HashType . L_ValueIs . FileHash . L_ChooseOp
  IfMsgBox No
  {
    IfExist, %HashFilePath%
    {
      HashValue:=GetHashFromText(Fname, HashFilePath, HashType)
      If (HashValue=False)
        Msgbox, 1, %L_Info%, %L_CantVerify%
      Else If (HashValue=FileHash)
        Msgbox, 1, %L_Info%, %L_FileOK%
      Else
        Msgbox, 1, %L_Info%, %L_FileBad%`n`n%Fname%
    }
    Else
    {
      HashFile := FileOpen(HashFilePath, "w")
      HashFile.WriteLine(FileHash . " *" . Fname)
      HashFile.Close()
    }
  }
}
IfMsgBox Yes
    Clipboard := FileHash
Exitapp

ChangeButtonNames:
IfWinNotExist, ahk_class #32770 ahk_pid %CurrentPID%
    Return
SetTimer, ChangeButtonNames, off 
WinActivate 
If (GetHashFileExt(HashType) <> False)
{
  ControlSetText, Button1, %L_Copy%
  IfExist, %HashFilePath%
    ControlSetText, Button2, %L_Verify%
  Else
    ControlSetText, Button2, %L_Save%
  ControlSetText, Button3, %L_Cancel%
}
Else
{
  ControlSetText, Button1, %L_Copy%
  ControlSetText, Button2, %L_Cancel%
}
Return

Exit:
Exitapp
Return

; MD2 ===============================================================================
FileMD2(filename)
{
    Return Crypt.Hash.FileHash(filename,2)
}
; MD4 ===============================================================================
FileMD4(filename)
{
    Return Crypt.Hash.FileHash(filename,7)
}
; MD5 ===============================================================================
FileMD5(filename)
{
    Return Crypt.Hash.FileHash(filename,1)
}
; SHA ===============================================================================
FileSHA1(filename)
{
    Return Crypt.Hash.FileHash(filename,3)
}
; SHA256 ============================================================================
FileSHA256(filename)
{
    Return Crypt.Hash.FileHash(filename,4)
}
; SHA384 ============================================================================
FileSHA384(filename)
{
    Return Crypt.Hash.FileHash(filename,5)
}
; SHA512 ============================================================================
FileSHA512(filename)
{
    Return Crypt.Hash.FileHash(filename,6)
}

; FileCRC32 =========================================================================
FileCRC32(sFile := "", cSz := 4)
{
    Bytes := ""
    cSz := (cSz < 0 || cSz > 8) ? 2**22 : 2**(18 + cSz)
    VarSetCapacity(Buffer, cSz, 0)
    hFil := DllCall("Kernel32.dll\CreateFile", "Str", sFile, "UInt", 0x80000000, "UInt", 3, "Int", 0, "UInt", 3, "UInt", 0, "Int", 0, "UInt")
    if (hFil < 1)
    {
        return hFil
    }
    hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
    CRC := 0
    DllCall("Kernel32.dll\GetFileSizeEx", "UInt", hFil, "Int64", &Buffer), fSz := NumGet(Buffer, 0, "Int64")
    loop % (fSz // cSz + !!Mod(fSz, cSz))
    {
        DllCall("Kernel32.dll\ReadFile", "UInt", hFil, "Ptr", &Buffer, "UInt", cSz, "UInt*", Bytes, "UInt", 0)
        CRC := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", CRC, "UInt", &Buffer, "UInt", Bytes, "UInt")
    }
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hFil)
    SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
    CRC := SubStr(CRC + 0x1000000000, -7)
    DllCall("User32.dll\CharLower", "Str", CRC)
    SetFormat, Integer, %A_FI%
    return CRC, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}

GetHashFileExt(HashType)
{
  If (HashType="SHA1")
    Return "SHA"
  Else If (HashType="MD5")
    Return "MD5"
  Else
    Return False
}

GetHashFromText(FileName, HashFilePath, HashType)
{
  HashLength := {CRC32: 8, MD2: 32, MD4: 32, MD5: 32, SHA1: 40, SHA256: 64, SHA384: 96, SHA512: 128}
  HashFile := FileOpen(HashFilePath, "r")
  Loop
  {
     LineText := HashFile.ReadLine()
     If (RegExMatch(LineText, "^\s*$") <> 0)
      Continue
     Else
     {
      RegExMatch(LineText, "i)^([0-9A-F]{" . HashLength[HashType] . "})\s+[*]{0,1}(.*\S)\s*$" , MatchPat)
      ;Msgbox |%MatchPat1%|%MatchPat2%|%FileName%|
      If (MatchPat2 = FileName)
      {
        HashFile.Close()
        Return MatchPat1
      }
     }
     If (HashFile.AtEOF)
      Break
   }
   HashFile.Close()
   Return False
}