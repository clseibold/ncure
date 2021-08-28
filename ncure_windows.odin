package ncure

import "core:strings"
import "core:strconv"
import "core:os"
import "core:fmt"
import "core:mem"
import "core:c"
import "core:sys/windows"

import "common"
import "vt100"

HANDLE :: windows.HANDLE;
TCHAR :: common.TCHAR;
COORD :: common.COORD;
SMALL_RECT :: common.SMALL_RECT;
CONSOLE_SCREEN_BUFFER_INFO :: common.CONSOLE_SCREEN_BUFFER_INFO;
CONSOLE_CURSOR_INFO :: common.CONSOLE_CURSOR_INFO;
FillConsoleOutputCharacterW :: common.FillConsoleOutputCharacterW;
FillConsoleOutputAttribute :: common.FillConsoleOutputAttribute;
GetConsoleScreenBufferInfo :: common.GetConsoleScreenBufferInfo;
GetConsoleCursorInfo :: common.GetConsoleCursorInfo;
SetConsoleCursorInfo :: common.SetConsoleCursorInfo;
SetConsoleCursorPosition :: common.SetConsoleCursorPosition;
SetConsoleTextAttribute :: common.SetConsoleTextAttribute;
NEWLINE :: common.NEWLINE;
SPACE_WCHAR := common.SPACE_WCHAR;

ForegroundColor :: common.ForegroundColor;
BackgroundColor :: common.BackgroundColor;
setColor :: common.setColor;
resetColors :: common.resetColors;

/*SPACE_WSTRING := windows.utf8_to_wstring(" ");
SPACE_WCHAR := mem.slice_ptr(SPACE_WSTRING, 1)[0];*/

// NOTE:
// Top-left for Windows (via win32 api) is (0, 0), while on linux, it is (1, 1)
// All cursor positions used in ncure start at (1, 1), which means
// all cursor positions are subtracted by 1 internally by ncure when setting the cursor.
// The user should not need to think about these differences.
// Also note that in VT100 mode on Windows, (1, 1) is the top-left internally,
// just like in linux, so no subtraction is needed.

@private
_ansiMode := false;
@private
_savedCursor := false;
@private
_cursor: CursorPos;
@private
hConsole := &common.hConsole;

enableAnsiMode :: proc() {
    _ansiMode = true;
}
enableVT100Mode :: enableAnsiMode;
disableAnsiMode :: proc() {
    _ansiMode = false;
}
disableVT100Mode :: disableAnsiMode;
setAnsiMode :: proc(on: bool) {
    _ansiMode = on;
}
setVT100Mode :: setAnsiMode;

initializeTerminal :: proc() {
    hConsole^ = windows.GetStdHandle(windows.STD_OUTPUT_HANDLE);
}

getTermSize :: common.getTermSize;
getCursor :: common.getCursor;

// Reset to initial state
reset :: proc() {
    if _ansiMode {
        vt100.reset();
        return;
    }

    // TODO
    unimplemented();
}

getCursor_topleft :: proc() -> CursorPos {
    if _ansiMode do return vt100.getCursor_topleft();

    return CursorPos { 1, 1 };
}

getCursor_topright :: proc(termSize: ^TermSize = nil) -> CursorPos {
    if _ansiMode do return vt100.getCursor_topright(termSize);

    newTermSize := getTermSize();
    if termSize != nil do termSize^ = newTermSize;

    return CursorPos { newTermSize.width, 1 };
}

getCursor_bottomleft :: proc(termSize: ^TermSize = nil) -> CursorPos {
    if _ansiMode do return vt100.getCursor_bottomleft(termSize);

    newTermSize := getTermSize();
    if termSize != nil do termSize^ = newTermSize;

    return CursorPos { 1, newTermSize.height };
}

getCursor_bottomright :: proc(termSize: ^TermSize = nil) -> CursorPos {
    if _ansiMode do return vt100.getCursor_bottomright(termSize);

    newTermSize := getTermSize();
    if termSize != nil do termSize^ = newTermSize;

    return CursorPos { newTermSize.width, newTermSize.height };
}

hideCursor :: proc() {
    if _ansiMode {
        vt100.hideCursor();
        return;
    }

    cursorInfo: CONSOLE_CURSOR_INFO;
    GetConsoleCursorInfo(hConsole^, &cursorInfo);

    if (cursorInfo.bVisible) {
        cursorInfo.bVisible = false;
        SetConsoleCursorInfo(hConsole^, &cursorInfo);
    }
}

showCursor :: proc() {
    if _ansiMode {
        vt100.showCursor();
        return;
    }

    cursorInfo: CONSOLE_CURSOR_INFO;
    GetConsoleCursorInfo(hConsole^, &cursorInfo);

    if (!cursorInfo.bVisible) {
        cursorInfo.bVisible = true;
        SetConsoleCursorInfo(hConsole^, &cursorInfo);
    }
}

saveCursor :: proc(overwrite := false) {
    if _ansiMode {
        vt100.saveCursor(overwrite);
        return;
    }

    if !overwrite {
		assert(!_savedCursor, "A cursor has already been saved without being restored.");
	}

    _cursor = getCursor();
}

restoreCursor :: proc() {
    if _ansiMode {
        vt100.restoreCursor();
        return;
    }

    _savedCursor = false;
    setCursor(_cursor);
}

save_restore :: proc(cursor: CursorPos, f: #type proc()) {
    if _ansiMode {
        vt100.save_restore(cursor, f);
        return;
    }

    saveCursor();
    setCursor(cursor);
    f();
    restoreCursor();
}

enableCursorBlinking :: proc() {
    if _ansiMode {
        vt100.enableCursorBlinking();
        return;
    }

    // TODO
    unimplemented();
}

disableCursorBlinking :: proc() {
    if _ansiMode {
        vt100.disableCursorBlinking();
        return;
    }

    // TODO
    unimplemented();
}

setCursor_xy :: proc(x, y: int, cursor: ^CursorPos = nil, savePrev := false) {
    if _ansiMode {
        vt100.setCursor_xy(x, y, cursor, savePrev);
        return;
    }

    pos: COORD = { i16(x) - 1, i16(y) - 1 };
    SetConsoleCursorPosition(hConsole^, pos);

    if cursor != nil {
        cursor.x = x;
        cursor.y = y;
    }
}
setCursor_cursor :: proc(cursor: CursorPos, savePrev := false) {
    if _ansiMode {
        vt100.setCursor_cursor(cursor, savePrev);
        return;
    }

    newPos: COORD = { i16(cursor.x) - 1, i16(cursor.y) - 1 };
    SetConsoleCursorPosition(hConsole^, newPos);
}
setCursor :: proc{setCursor_xy, setCursor_cursor};

setCursor_topleft :: proc(cursor: ^CursorPos = nil, savePrev := false) {
    if _ansiMode {
        vt100.setCursor_topleft(cursor, savePrev);
        return;
    }

    newCursor := getCursor_topleft();
    setCursor(newCursor);

    if cursor != nil do cursor^ = newCursor;
}
setCursor_topright :: proc(termSize: ^TermSize = nil, cursor: ^CursorPos = nil, savePrev := false) {
    if _ansiMode {
        vt100.setCursor_topright(termSize, cursor, savePrev);
        return;
    }

    newCursor := getCursor_topright(termSize);
    setCursor(newCursor);

    if cursor != nil do cursor^ = newCursor;
}
setCursor_bottomleft :: proc(termSize: ^TermSize = nil, cursor: ^CursorPos = nil, savePrev := false) {
    if _ansiMode {
        vt100.setCursor_bottomleft(termSize, cursor, savePrev);
        return;
    }

    newCursor := getCursor_bottomleft(termSize);
    setCursor(newCursor);

    if cursor != nil do cursor^ = newCursor;
}
setCursor_bottomright :: proc(termSize: ^TermSize = nil, cursor: ^CursorPos = nil, savePrev := false) {
    if _ansiMode {
        vt100.setCursor_bottomright(termSize, cursor, savePrev);
        return;
    }

    newCursor := getCursor_bottomright(termSize);
    setCursor(newCursor);

    if cursor != nil do cursor^ = newCursor;
}

moveCursor_up :: proc(amt: int = 1) {
    if _ansiMode {
        vt100.moveCursor_up(amt);
        return;
    }

    currentPos := getCursor();
    currentPos.y -= amt;
    setCursor(currentPos);
}

moveCursor_down :: proc(amt: int = 1) {
    if _ansiMode {
        vt100.moveCursor_down(amt);
        return;
    }

    currentPos := getCursor();
    currentPos.y += amt;
    setCursor(currentPos);
}

moveCursor_left :: proc(amt: int = 1) {
    if _ansiMode {
        vt100.moveCursor_left(amt);
        return;
    }

    currentPos := getCursor();
    currentPos.x -= amt;
    setCursor(currentPos);
}

moveCursor_right :: proc(amt: int = 1) {
    if _ansiMode {
        vt100.moveCursor_right(amt);
        return;
    }

    currentPos := getCursor();
    currentPos.x += amt;
    setCursor(currentPos);
}

moveCursor_start :: proc() {
    if _ansiMode {
        vt100.moveCursor_start();
        return;
    }

    os.write_byte(os.stdout, '\r');
}

moveCursor_end :: proc() { // TODO: Check this
    if _ansiMode {
        vt100.moveCursor_end();
        return;
    }

    ts: TermSize = getTermSize();
    currentPos := getCursor();
    os.write_byte(os.stdout, '\r');
    setCursor(int(ts.width), int(currentPos.y));
}

clearScreen :: proc() {
    if _ansiMode {
        vt100.clearScreen();
        return;
    }

    writePos :: COORD { 0, 0 };

    consoleInfo: CONSOLE_SCREEN_BUFFER_INFO;
    GetConsoleScreenBufferInfo(hConsole^, &consoleInfo);

    consoleArea: windows.DWORD = cast(windows.DWORD) (consoleInfo.dwSize.X * consoleInfo.dwSize.Y);
    _writeChars(SPACE_WCHAR, writePos, &consoleInfo, consoleArea);
}

clearLine :: proc() {
    if _ansiMode {
        vt100.clearLine();
        return;
    }

    termSize := getTermSize();
    pos := getCursor();

    amt := termSize.width - 1; // TODO

    consoleInfo: CONSOLE_SCREEN_BUFFER_INFO;
    GetConsoleScreenBufferInfo(hConsole^, &consoleInfo);

    writePos := COORD { 0, i16(pos.y) - 1 };
    _writeChars(SPACE_WCHAR, writePos, &consoleInfo, u32(amt));
}

clearLine_right :: proc() {
    if _ansiMode {
        vt100.clearLine_right();
        return;
    }

    termSize := getTermSize();
    pos := getCursor();

    amt := termSize.width - pos.x;

    consoleInfo: CONSOLE_SCREEN_BUFFER_INFO;
    GetConsoleScreenBufferInfo(hConsole^, &consoleInfo);

    writePos := COORD { i16(pos.x) - 1, i16(pos.y) - 1 };
    _writeChars(SPACE_WCHAR, writePos, &consoleInfo, u32(amt));
}

clearLine_left :: proc() {
    if _ansiMode {
        vt100.clearLine_left();
        return;
    }

    pos := getCursor();

    amt := pos.x - 1;

    consoleInfo: CONSOLE_SCREEN_BUFFER_INFO;
    GetConsoleScreenBufferInfo(hConsole^, &consoleInfo);

    writePos := COORD { 0, i16(pos.y) - 1 };
    _writeChars(SPACE_WCHAR, writePos, &consoleInfo, u32(amt));
}

backspace :: proc(amt := 1, clear := true) {
    if _ansiMode {
        vt100.backspace(amt, clear);
        return;
    }

    moveCursor_left(amt);
    if clear do clearLine_right();
    else {
        for i in 0..<amt {
            os.write_string(os.stdout, " ");
        }
        moveCursor_left(amt);
    }
}

// NOTE: writePos should already use win32 coordinates
_writeChars :: proc(character: TCHAR, writePos: COORD, consoleInfo: ^CONSOLE_SCREEN_BUFFER_INFO, amt: c.ulong) -> windows.DWORD {
    charsWritten: windows.DWORD;
    newWritePos: COORD = { writePos.X, writePos.Y };

    FillConsoleOutputCharacterW(hConsole^, character, amt, newWritePos, &charsWritten); // TODO: Check if failed?
    GetConsoleScreenBufferInfo(hConsole^, consoleInfo);
    FillConsoleOutputAttribute(hConsole^, consoleInfo.wAttributes, amt, newWritePos, &charsWritten);

    return charsWritten;
}
