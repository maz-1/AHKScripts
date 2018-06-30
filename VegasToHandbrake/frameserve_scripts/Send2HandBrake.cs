using System;
using System.Threading;
using System.Collections;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.Windows.Forms;
using Microsoft.Win32;
using System.Runtime.InteropServices;
using System.Reflection;
//using Sony.Vegas;  //old version for version <14
using ScriptPortal.Vegas; //for version 14+

public class EntryPoint {
  //string VegasDir=Path.GetDirectoryName(Process.GetCurrentProcess().MainModule.FileName);
  string VegasDir = Environment.GetEnvironmentVariable("PROGRAMDATA") + "\\VEGAS Pro";
  string OutFileName=Convert.ToString(Process.GetCurrentProcess().Id);
  string StartScriptData="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";
  Track TargetTrack;
  VideoEvent emptyEvent;
  
  [DllImport("kernel32.dll", CharSet=CharSet.Auto, SetLastError=true)]
  static extern bool SetDllDirectory(string lpPathName);

  [DllImport("Autohotkey.dll", CharSet=CharSet.Unicode, CallingConvention=CallingConvention.Cdecl)]
  public static extern uint ahktextdll(
      [MarshalAs(UnmanagedType.LPWStr)] string Code,
      [MarshalAs(UnmanagedType.LPWStr)] string Options,
      [MarshalAs(UnmanagedType.LPWStr)] string Parameters);

  [DllImport("Autohotkey.dll", CharSet=CharSet.Unicode, CallingConvention=CallingConvention.Cdecl)]
  public static extern bool ahkassign(
      [MarshalAs(UnmanagedType.LPWStr)] string VariableName,
      [MarshalAs(UnmanagedType.LPWStr)] string NewValue);

  [DllImport("Autohotkey.dll", CharSet=CharSet.Unicode, CallingConvention=CallingConvention.Cdecl)]
  public static extern void ahkPause(
      [MarshalAs(UnmanagedType.LPWStr)] string strState);

  [DllImport("Autohotkey.dll", CharSet=CharSet.Unicode, CallingConvention=CallingConvention.Cdecl)]
  public static extern bool ahkReady();

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
    if (vegas.Project.Length.ToMilliseconds() == 0)
      return;
    SetDllDirectory(VegasDir+"\\Script Depends");
    string RegKey = "HKEY_CURRENT_USER\\Software\\Sony Creative Software\\Vegas Pro\\frameserver";
    int AddBuffer = 1; int RenderLoop = 1; string outputDirectory = "";
    try {
      AddBuffer = (int) Registry.GetValue(RegKey, "AddBuffer", 1);
      RenderLoop = (int) Registry.GetValue(RegKey, "RenderLoopRegion", 1);
      outputDirectory = (string) Registry.GetValue(RegKey, "TempDir", "");
    } catch {}
    string outDirDefualt = Environment.GetEnvironmentVariable("TEMP") + "\\frameserver";
    if (outputDirectory == "")
      outputDirectory = outDirDefualt;
    if (!Directory.Exists(outputDirectory))
    {
      try {
        Directory.CreateDirectory(outputDirectory);
      } catch {
        outputDirectory = outDirDefualt;
        Directory.CreateDirectory(outputDirectory);
      }
    }
    
    // Start virtual file system, AviSynth and HandBrake
    ahktextdll(Unzip(Convert.FromBase64String(StartScriptData)), "",  "");
    while (!ahkReady()) Thread.Sleep(100);
    ahkassign("TempFileDir", outputDirectory);
    ahkassign("AddBuffer", AddBuffer.ToString());
    ahkassign("RegKey", RegKey);
    ahkassign("VegasDir", VegasDir);
    ahkPause("Off");
    
    Regex videoRendererRegexp = new Regex(@"DebugMode FrameServer", RegexOptions.Compiled | RegexOptions.IgnoreCase);
    Regex videoTemplateRegexp = new Regex(@"Project Default", RegexOptions.Compiled | RegexOptions.IgnoreCase);
    try
    {
    //Add an empty event to first video track to solve frameserver audio bug
      if (AddBuffer>0)
      {
        foreach (Track CurTrack in vegas.Project.Tracks)
        {
          if (CurTrack.IsVideo())
          {
            TargetTrack = CurTrack;
            emptyEvent = new VideoEvent(vegas.Project, vegas.Project.Length, Timecode.FromMilliseconds(1000), null);
            CurTrack.Events.Add(emptyEvent);
            break;
          }
        }
      }
      // Check timeline's loop-region
      Timecode renderStart = new Timecode();
      Timecode renderLength = vegas.Project.Length;
      if (RenderLoop>0)
      {
        renderStart = vegas.SelectionStart;
        if (AddBuffer>0)
          renderLength = vegas.SelectionLength + Timecode.FromMilliseconds(1000);
        else
          renderLength = vegas.SelectionLength;
      }
      
      //Define export path and file name
      string projDir, projName, videoOutputFile;
      string projFile = vegas.Project.FilePath;
      if ((null == projFile) || (0 == projFile.Length))
      {
        projDir = "";
        projName = "Untitled";
      }
      else
      {
        projDir = Path.GetDirectoryName(projFile) + Path.DirectorySeparatorChar;
        projName = Path.GetFileNameWithoutExtension(projFile);
      }
      videoOutputFile = outputDirectory + "\\" + OutFileName + ".avi";
      if (null == videoOutputFile)
        throw new Exception("Process terminated");
      Renderer aviRenderer = FindRenderer(videoRendererRegexp, vegas);
      if (null == aviRenderer)
        throw new Exception("Could not find DebugMode FrameServer");
      
      // Start export
      RenderTemplate videoTemplate = FindRenderTemplate(aviRenderer, videoTemplateRegexp, vegas);
      if (null == videoTemplate)
        throw new Exception("Could not find the render preset defined by the script");
      RenderStatus renderStatus = vegas.Render(videoOutputFile, videoTemplate, renderStart, renderLength);
      if (AddBuffer>0) TargetTrack.Events.Remove(emptyEvent);
    } catch (Exception ex) {
      if (AddBuffer>0) TargetTrack.Events.Remove(emptyEvent);
      MessageBox.Show(ex.ToString());
    }
    
  }
  
  public Renderer FindRenderer(Regex re, Vegas vegas)
  {
    foreach (Renderer renderer in vegas.Renderers)
    {
      if (re.IsMatch(renderer.FileTypeName))
        return renderer;
    }
    return null;
  }
  
  public RenderTemplate FindRenderTemplate(Renderer renderer, Regex re, Vegas vegas)
  {
    foreach (RenderTemplate renderTemplate in renderer.Templates)
    {
      if (re.IsMatch(renderTemplate.Name))
        return renderTemplate;
    }
    return null;
  }
  
}