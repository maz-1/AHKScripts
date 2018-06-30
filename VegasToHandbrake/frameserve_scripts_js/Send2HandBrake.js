import System;
//import Sony.Vegas;  //old version for version <14
import ScriptPortal.Vegas; //for version 14+
import System.IO;
import System.IO.Compression;
import System.Diagnostics;
import System.Windows.Forms;
import Microsoft.Win32;
import System.Reflection;
import System.Reflection.Emit;
import System.Runtime;
import System.Text;

var VegasDir = Path.GetDirectoryName(Process.GetCurrentProcess().MainModule.FileName);
//Vegas.Project.FilePath.match(/^.*[\\\/](.*)\.\S{3}/)[1]
//var OutFileName = "vegas";
var OutFileName = Process.GetCurrentProcess().Id;

// Read preferences
var AddBuffer = Registry.GetValue("HKEY_CURRENT_USER\\Software\\Sony Creative Software\\Vegas Pro\\frameserver", "AddBuffer", true);
var RenderLoop = Registry.GetValue("HKEY_CURRENT_USER\\Software\\Sony Creative Software\\Vegas Pro\\frameserver", "RenderLoopRegion", true);
var ScriptDir = Registry.GetValue("HKEY_LOCAL_MACHINE\\SOFTWARE\\Sony Creative Software\\Vegas Pro\\frameserver", "ScriptDir", null);
var outDirDefualt = Environment.GetEnvironmentVariable("TEMP") + "\\frameserver";
var outputDirectory = Registry.GetValue("HKEY_CURRENT_USER\\Software\\Sony Creative Software\\Vegas Pro\\frameserver", "TempDir", "");
if (outputDirectory == "")
  outputDirectory = outDirDefualt;
if (!Directory.Exists(outputDirectory))
{
  try {
    Directory.CreateDirectory(outputDirectory);
  } catch (e) {
    outputDirectory = outDirDefualt;
    Directory.CreateDirectory(outputDirectory);
  }
}
// Start virtual file system, AviSynth and HandBrake
var StartScriptData = "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";

AHKTextDll(Unzip(Convert.FromBase64String(StartScriptData)), '', '"'+outputDirectory+'" "'+VegasDir+'"');

// Define DebugMode FrameServer as renderer
var videoRendererRegexp = /DebugMode FrameServer/;
var videoTemplateRegexp = /Project Default/;

try 
{
    
//Add an empty event to first video track to solve frameserver bug
    if (AddBuffer)
    {
      var TracksE = new Enumerator(Vegas.Project.Tracks);
      while (true) {
        var CurTrack = TracksE.item();
        if (CurTrack.IsVideo())
        {
          var emptyEvent = new VideoEvent(Vegas.Project, Vegas.Project.Length, Timecode.FromMilliseconds(1000), null);
          CurTrack.Events.Add(emptyEvent);
          break;
        }
        if (TracksE.atEnd())
          break;
        TracksE.moveNext();
      }
    }
    
// Check timeline's loop-region
    var renderStart = new Timecode();
    var renderLength = Vegas.Project.Length;
    if (RenderLoop)
		{
            renderStart = Vegas.SelectionStart;
            renderLength = Vegas.SelectionLength;
		}
    
//Define export path and file name
    var projDir, projName, videoOutputFile;
    var projFile = Vegas.Project.FilePath;
    if ((null == projFile) || (0 == projFile.length)) 
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
        throw "Process terminated";
    var aviRenderer = findRenderer(videoRendererRegexp);
    if (null == aviRenderer)
        throw "Could not find DebugMode FrameServer";

// Start export
    var videoTemplate = findTemplate(aviRenderer, videoTemplateRegexp);
    if (null == videoTemplate)
        throw "Could not find the render preset defined by the script";
    var renderStatus = Vegas.Render(videoOutputFile, videoTemplate, renderStart, renderLength);
    //if (renderStatus != RenderStatus.Complete)
    //    throw "Render process not completed";
    if (AddBuffer) CurTrack.Events.Remove(emptyEvent); // Remove empty event
    
} catch (e) 

	{
    if (AddBuffer) CurTrack.Events.Remove(emptyEvent); // Remove empty event
    MessageBox.Show(e);
	}

// Find renderer
function findRenderer(re) 
	{
    var rendererEnum = new Enumerator(Vegas.Renderers);
    while (!rendererEnum.atEnd()) 
		{
        var renderer = rendererEnum.item();
        if (null != renderer.FileTypeName.match(re)) 
			{
            return renderer;
			}
        rendererEnum.moveNext();
    		}
    return null;
	}

//Find render preset
function findTemplate(renderer, re) 
	{
    var templateEnum = new Enumerator(renderer.Templates);
    while (!templateEnum.atEnd()) 
		{
        var template = templateEnum.item();
        if (null != template.Name.match(re)) 
			{
            return template;
        			}
        templateEnum.moveNext();
    		}
    return null;
	}

function InvokeWin32(dllName:String, returnType:Type,
  methodName:String, parameterTypes:Type[], parameters:Object[])
{
  var domain = AppDomain.CurrentDomain;
  var name = new System.Reflection.AssemblyName('PInvokeAssembly');
  var assembly = domain.DefineDynamicAssembly(name, AssemblyBuilderAccess.Run);
  var module = assembly.DefineDynamicModule('PInvokeModule');
  var type = module.DefineType('PInvokeType',TypeAttributes.Public + TypeAttributes.BeforeFieldInit);
  var method = type.DefineMethod(methodName, MethodAttributes.Public + MethodAttributes.HideBySig + MethodAttributes.Static + MethodAttributes.PinvokeImpl, returnType, parameterTypes);
  var ctor = System.Runtime.InteropServices.DllImportAttribute.GetConstructor([Type.GetType("System.String")]);
  var attr = new System.Reflection.Emit.CustomAttributeBuilder(ctor, [dllName]);
  method.SetCustomAttribute(attr);
  var realType = type.CreateType();
  return realType.InvokeMember(methodName, BindingFlags.Public + BindingFlags.Static + BindingFlags.InvokeMethod, null, null, parameters);
}
 
function AHKTextDll(lpScript:String, lpOptions:String, lpParameters:String) 
{ 
   var parameterTypes:Type[] = [Type.GetType("System.String"),Type.GetType("System.String"),Type.GetType("System.String")];
   var parameters:Object[] = [Encoding.Default.GetString(Encoding.Unicode.GetBytes(lpScript)), Encoding.Default.GetString(Encoding.Unicode.GetBytes(lpOptions)), Encoding.Default.GetString(Encoding.Unicode.GetBytes(lpParameters))];
   return InvokeWin32(VegasDir+"\\Script Depends\\Autohotkey.dll", Type.GetType("System.Int32"), "ahktextdll", parameterTypes,  parameters );
}

function Unzip(bytes:Byte[]) {
  var msi = new MemoryStream(bytes);
  var mso = new MemoryStream();
  var gs = new GZipStream(msi, CompressionMode.Decompress);
  gs.CopyTo(mso);
  var str = Encoding.UTF8.GetString(mso.ToArray());
  gs.Dispose();
  msi.Dispose();
  mso.Dispose();
  return str;
}