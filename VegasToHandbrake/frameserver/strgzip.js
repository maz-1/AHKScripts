import System;
import System.Text;
import System.IO;
import System.IO.Compression;
import System.Windows.Forms;
import System.Diagnostics;


var openFileDialog1 = new OpenFileDialog();
openFileDialog1.RestoreDirectory = true ;
openFileDialog1.Multiselect = false;
if(openFileDialog1.ShowDialog() == DialogResult.OK)
{
  try
  {
      var InFile = openFileDialog1.FileName;
      if (InFile)
      {
        var line;
        var fileContent="";
        var sr = new StreamReader(InFile)
        var ignorePatt = /^\s*(;|$)/;
        while((line = sr.ReadLine()) != null)
        {
          if (ignorePatt.test(line))
            continue;
          line = line.replace(/^\s+/, "");
          fileContent+=line+"\n"
        }
        var compressedtext = Convert.ToBase64String(Zip(fileContent));
        //MessageBox.Show(compressedtext);
        Clipboard.SetText('"'+compressedtext+'";');
        //MessageBox.Show(fileContent);
      }
  }
  catch (e)
  {
    MessageBox.Show(e);
  }
}


function Zip(str:String) {
    var bytes = Encoding.UTF8.GetBytes(str);
    var msi = new MemoryStream(bytes);
    var mso = new MemoryStream();
    var gs = new GZipStream(mso, CompressionMode.Compress);
        msi.CopyTo(gs);
        msi.Dispose();
        //mso.Dispose();
        gs.Dispose();
        return mso.ToArray();
}

function Unzip(bytes:Byte[]) {
    var msi = new MemoryStream(bytes);
    var mso = new MemoryStream();
    var gs = new GZipStream(msi, CompressionMode.Decompress);
        gs.CopyTo(mso);
        msi.Dispose();
        gs.Dispose();
        var str = Encoding.UTF8.GetString(mso.ToArray());
        mso.Dispose();
        return str;
}

//var rawtext = "The white-space characters, and their Unicode names and hexadecimal code points, are tab (CHARACTER TABULATION, U+0009), newline (LINE FEED, U+000A), carriage return (CARRIAGE RETURN, U+000D), and blank (SPACE, U+0020). An arbitrary number of white-space characters can appear in s because all white-space characters are ignored.";
//var compressedtext = Convert.ToBase64String(Zip(rawtext));
//var restoredtext = Unzip(Convert.FromBase64String(compressedtext));


//MessageBox.Show(compressedtext);
//MessageBox.Show(restoredtext);