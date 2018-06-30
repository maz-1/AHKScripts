DownloadFile(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True, FileSize := 0) {
      Global WebRequest
      If (!Overwrite && FileExist(SaveFileAs))
          Return 1
      If (UseProgressBar) {
        If (FileSize=0)
        {
            If (!WebRequest)
              WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            WebRequest.Open("HEAD", UrlToFile)
            Try
              WebRequest.Send()
            Catch
              Return 1
            FinalSize := WebRequest.GetResponseHeader("Content-Length")
        }
        Else
            FinalSize := FileSize
        Progress, H80, , Downloading..., %UrlToFile%
        SetTimer, __UpdateProgressBar, 200
      }
      UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
      DownloadStat:=ErrorLevel
      If (UseProgressBar) {
          Progress, Off
          SetTimer, __UpdateProgressBar, Off
      }
    Return DownloadStat
      __UpdateProgressBar:
            CurrentSize := FileOpen(SaveFileAs, "r").Length
            CurrentSizeTick := A_TickCount
            Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
            LastSizeTick := CurrentSizeTick
            LastSize := FileOpen(SaveFileAs, "r").Length
            PercentDone := Round(CurrentSize/FinalSize*100)
            Progress, %PercentDone%, %PercentDone%`% Done, Downloading...  (%Speed%), Downloading %SaveFileAs% (%PercentDone%`%)
      Return
}

GetOnlineSize(UrlToFile)
{
  Global WebRequest
  If (!WebRequest)
    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  WebRequest.Open("HEAD", UrlToFile)
  Try
    WebRequest.Send()
  Catch
    Return 0
  Return WebRequest.GetResponseHeader("Content-Length")
}