import winim, ptr_math

proc string(chars: openArray[WCHAR]): string =
    var final: string
    for character in chars:
        let char = chr(character)
        if char == '\x00' or char == '\0':
            continue
        
        final.add(char)
    return final
    
proc string(pvoid: PVOID): string = return $(cast[LPCSTR](pvoid))
proc findProc(name: string): DWORD =
    var pe32: PROCESSENTRY32
    pe32.dwSize = sizeof(PROCESSENTRY32).DWORD
    let snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    Process32First(snapshot, addr pe32)
    while Process32Next(snapshot, addr pe32) != 0:
        let pname = pe32.szExeFile
        if pname.string == name:
            return pe32.th32ProcessID

proc procInfo(name: string) =
    let PID = findProc(name)
    let hProc = OpenProcess(PROCESS_ALL_ACCESS, false, PID)
    var pbi: PROCESS_BASIC_INFORMATION
    var returnLen: ULONG
    let status = NtQueryInformationProcess(
        hProc,
        cast[PROCESSINFOCLASS](0),
        &pbi,
        sizeof(PROCESS_BASIC_INFORMATION).ULONG,
        addr returnLen
    )
    let pebAddr = cast[PVOID](pbi.PebBaseAddress)
    echo(status)
    echo(repr(cast[PVOID](pbi.PebBaseAddress)))

procInfo("notepad.exe")