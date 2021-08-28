package ncure_common

import "core:os"
import "core:strings"
import "core:strconv"
import "core:sys/windows"

FOREGROUND_BLUE      :: 0x0001; // text color contains blue.
FOREGROUND_GREEN     :: 0x0002; // text color contains green.
FOREGROUND_RED       :: 0x0004; // text color contains red.
FOREGROUND_INTENSITY :: 0x0008; // text color is intensified.

BACKGROUND_BLUE      :: 0x0010; // background color contains blue.
BACKGROUND_GREEN     :: 0x0020; // background color contains green.
BACKGROUND_RED       :: 0x0040; // background color contains red.
BACKGROUND_INTENSITY :: 0x0080; // background color is intensified.

_colorToAttribute_foreground :: proc(fg: ForegroundColor) -> windows.WORD {
    color: windows.WORD = 0;
    switch (fg) {
        case .Red: color = FOREGROUND_RED;
        case .BrightRed: color = FOREGROUND_RED | FOREGROUND_INTENSITY;
        case .Green: color = FOREGROUND_GREEN;
        case .BrightGreen: color = FOREGROUND_GREEN | FOREGROUND_INTENSITY;
        case .Blue: color = FOREGROUND_BLUE;
        case .BrightBlue: color = FOREGROUND_BLUE | FOREGROUND_INTENSITY;

        case .Yellow: color = FOREGROUND_RED | FOREGROUND_GREEN;
        case .BrightYellow: color = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_INTENSITY;
        case .Cyan: color = FOREGROUND_GREEN | FOREGROUND_BLUE;
        case .BrightCyan: color = FOREGROUND_GREEN | FOREGROUND_BLUE | FOREGROUND_INTENSITY;
        case .Magenta: color = FOREGROUND_RED | FOREGROUND_BLUE;
        case .BrightMagenta: color = FOREGROUND_RED | FOREGROUND_BLUE | FOREGROUND_INTENSITY;

        case .White: color = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        case .BrightWhite: color = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE | FOREGROUND_INTENSITY;
        case .Black:
        case .Grey: color = FOREGROUND_INTENSITY;
    }

    return color;
}
_colorToAttribute_background :: proc(bg: BackgroundColor) -> windows.WORD {
    color: windows.WORD = 0;
    switch (bg) {
        case .Red: color = BACKGROUND_RED;
        case .BrightRed: color = BACKGROUND_RED | BACKGROUND_INTENSITY;
        case .Green: color = BACKGROUND_GREEN;
        case .BrightGreen: color = BACKGROUND_GREEN | BACKGROUND_INTENSITY;
        case .Blue: color = BACKGROUND_BLUE;
        case .BrightBlue: color = BACKGROUND_BLUE | BACKGROUND_INTENSITY;

        case .Yellow: color = BACKGROUND_RED | BACKGROUND_GREEN;
        case .BrightYellow: color = BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_INTENSITY;
        case .Cyan: color = BACKGROUND_GREEN | BACKGROUND_BLUE;
        case .BrightCyan: color = BACKGROUND_GREEN | BACKGROUND_BLUE | BACKGROUND_INTENSITY;
        case .Magenta: color = BACKGROUND_RED | BACKGROUND_BLUE;
        case .BrightMagenta: color = BACKGROUND_RED | BACKGROUND_BLUE | BACKGROUND_INTENSITY;

        case .White: color = BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
        case .BrightWhite: color = BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE | BACKGROUND_INTENSITY;
        case .Black:
        case .Grey: color = BACKGROUND_INTENSITY;
    }

    return color;
}

setColor_foreground :: proc(fg: ForegroundColor) {
    color := _colorToAttribute_foreground(fg);
    SetConsoleTextAttribute(hConsole, color);
}

setColor_background :: proc(bg: BackgroundColor) {
    color := _colorToAttribute_background(bg);
    SetConsoleTextAttribute(hConsole, color);
}

setColor_fg_bg :: proc(fg: ForegroundColor, bg: BackgroundColor) {
    color := _colorToAttribute_foreground(fg);
    color |= _colorToAttribute_background(bg);
    SetConsoleTextAttribute(hConsole, color);
}

setColor :: proc{setColor_foreground, setColor_background, setColor_fg_bg};

resetColors :: proc() {
    color: windows.WORD = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
    SetConsoleTextAttribute(hConsole, color);
}

