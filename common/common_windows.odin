package ncure_common

import "core:sys/windows"
import "core:c"
foreign import kernel32 "system:Kernel32.lib"

hConsole: windows.HANDLE;

TCHAR :: windows.WCHAR;
SPACE_WCHAR := cast(TCHAR) ' ';

COORD :: struct {
    X: windows.SHORT,
    Y: windows.SHORT,
}

SMALL_RECT :: struct {
    Left: windows.SHORT,
    Top: windows.SHORT,
    Right: windows.SHORT,
    Bottom: windows.SHORT,
}

CONSOLE_SCREEN_BUFFER_INFO :: struct {
    dwSize: COORD,
    dwCursorPosition: COORD,
    wAttributes: windows.WORD,
    srWindow: SMALL_RECT,
    dwMaximumWindowSize: COORD,
}

CONSOLE_CURSOR_INFO :: struct {
  dwSize: windows.DWORD,
  bVisible: windows.BOOL,
}

@(default_calling_convention="stdcall")
foreign kernel32 {
    FillConsoleOutputCharacterW :: proc(hConsoleOutput: windows.HANDLE,
                                        cCharacter: TCHAR,
                                        nLength: windows.DWORD,
                                        dwWriteCoord: COORD,
                                        lpNumberOfCharsWritten: windows.LPDWORD) -> windows.BOOL ---;
    FillConsoleOutputAttribute :: proc(hConsoleOutput: windows.HANDLE,
                                        wAttribute: windows.WORD,
                                        nLength: windows.DWORD,
                                        dwWriteCoord: COORD,
                                        lpNumberOfCharsWritten: windows.LPDWORD) -> windows.BOOL ---;
    GetConsoleScreenBufferInfo :: proc(hConsoleOutput: windows.HANDLE,
                                        lpConsoleScreenBufferInfo: ^CONSOLE_SCREEN_BUFFER_INFO) -> windows.BOOL ---;
    GetConsoleCursorInfo :: proc(hConsoleOutput: windows.HANDLE, lpConsoleCursorInfo: ^CONSOLE_CURSOR_INFO) -> windows.BOOL ---;
    SetConsoleCursorInfo :: proc(hConsoleOutput: windows.HANDLE,
                                lpConsoleCursorInfo: ^CONSOLE_CURSOR_INFO) -> windows.BOOL ---;
    SetConsoleCursorPosition :: proc(hConsoleOutput: windows.HANDLE, dwCursorPosition: COORD) -> windows.BOOL ---;
    SetConsoleTextAttribute :: proc(hConsoleOutput: windows.HANDLE, wAttributes: windows.WORD) -> windows.BOOL ---;

    _getch :: proc() -> windows.INT ---;
}

// ----- ncure stuff -----

NEWLINE :: "\r\n";

getTermSize :: proc() -> TermSize {
    consoleInfo: CONSOLE_SCREEN_BUFFER_INFO;
    GetConsoleScreenBufferInfo(hConsole, &consoleInfo);

    return TermSize { int(consoleInfo.srWindow.Right) - int(consoleInfo.srWindow.Left) + 1, int(consoleInfo.srWindow.Bottom) - int(consoleInfo.srWindow.Top) + 1 };
}

// TODO: When the linux version is fixed, move this back to ncure_windows.odin
// One is added to convert the cursor coordinates to the system used by ncure,
// where (1, 1) is always top-left.
getCursor :: proc() -> CursorPos {
    consoleInfo: CONSOLE_SCREEN_BUFFER_INFO;
    GetConsoleScreenBufferInfo(hConsole, &consoleInfo);

    return CursorPos { int(consoleInfo.dwCursorPosition.X) + 1, int(consoleInfo.dwCursorPosition.Y) + 1 };
}
