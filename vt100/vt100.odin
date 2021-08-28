package vt100

// Note that (1, 1) is always the top-left on both Linux and Windows
// when using VT100 mode. This is different from using the win32 api
// on Windows, where (0, 0) is top-left (although, ncure handles these
// conversions internally, so users should not need to handle this difference
// themselves).

import "core:os"
import "core:strings"
import "core:strconv"
import "core:fmt"
import "../common"

NEWLINE :: common.NEWLINE;
getTermSize :: common.getTermSize;
getCursor :: common.getCursor; // TODO: See common_linux.odin
CursorPos :: common.CursorPos;
TermSize :: common.TermSize;

ForegroundColor :: common.ForegroundColor;
BackgroundColor :: common.BackgroundColor;
setColor :: common.setColor;
resetColors :: common.resetColors;

ESC :: "\e";
SEQUENCE_START :: "\e[";

RESET :: "\ec";

CLEAR :: "\e[2J";
CLEAR_DOWN :: "\e[J";
CLEAR_UP :: "\e[1J";
CLEAR_LINE :: "\e[2K";
CLEAR_LINE_RIGHT :: "\e[K";
CLEAR_LINE_LEFT :: "\e[1K";

TOP_LEFT :: "\e[1;1H";

GET_CURSOR :: "\e[6n";
HIDE_CURSOR :: "\e[?25l"; // VT220
SHOW_CURSOR :: "\e[?25h"; // VT220
SAVE_CURSOR :: "\e7";
RESTORE_CURSOR :: "\e8";

ENABLE_CURSOR_BLINKING :: "\e[?12h";
DISABLE_CURSOR_BLINKING :: "\e[?12l";

MOVE_UP :: "\e[1A";
MOVE_DOWN :: "\e[1B";
MOVE_LEFT :: "\e[1D";
MOVE_RIGHT :: "\e[1C";

@private
_savedCursor := false;

// Reset to initial state
reset :: proc() {
	os.write_string(os.stdout, RESET);
}

getCursor_topleft :: proc() -> CursorPos {
	return CursorPos {1, 1};
}

getCursor_topright :: proc(termSize: ^TermSize = nil) -> CursorPos {
	new_ts: TermSize;
	
    new_ts = getTermSize();
    if termSize != nil do termSize^ = new_ts;
	
	return CursorPos {new_ts.width, 1};
}

getCursor_bottomleft :: proc(termSize: ^TermSize = nil) -> CursorPos {
	new_ts: TermSize;
	
    new_ts = getTermSize();
    if termSize != nil do termSize^ = new_ts;
	
	return CursorPos {1, new_ts.height};
}

getCursor_bottomright :: proc(termSize: ^TermSize = nil) -> CursorPos {
	new_ts: TermSize;
	
    new_ts = getTermSize();
    if termSize != nil do termSize^ = new_ts;
	
	return CursorPos {new_ts.width, new_ts.height};
}

hideCursor :: proc() {
    os.write_string(os.stdout, HIDE_CURSOR);
}

showCursor :: proc() {
    os.write_string(os.stdout, SHOW_CURSOR);
}

saveCursor :: proc(overwrite := false) {
	if !overwrite {
		assert(!_savedCursor, "A cursor has already been saved without being restored.");
	}
	
    _savedCursor = true;
    os.write_string(os.stdout, SAVE_CURSOR);
}

restoreCursor :: proc() {
    _savedCursor = false;
    os.write_string(os.stdout, RESTORE_CURSOR);
}

save_restore :: proc(cursor: CursorPos, f: #type proc()) {
	saveCursor();
	setCursor(cursor);
	f();
	restoreCursor();
}

enableCursorBlinking :: proc() {
	os.write_string(os.stdout, ENABLE_CURSOR_BLINKING);
}

disableCursorBlinking :: proc() {
	os.write_string(os.stdout, DISABLE_CURSOR_BLINKING);
}

getSequence_set :: proc(x, y: int, b: ^strings.Builder = nil) -> string {
	if x == 1 && y == 1 {
		if b != nil {
			strings.write_string(b, TOP_LEFT);
			return strings.to_string(b^);
		}
		return strings.clone(TOP_LEFT);
	}
	
	buf: [129]byte;
	builder_new: strings.Builder;
	builder: ^strings.Builder = b;
	if b == nil {
		// Create new builder for this sequence only if not
		// being added to a pre-existing builder.
		builder_new = strings.make_builder();
		builder = &builder_new;
	}
	
	strings.write_string(builder, SEQUENCE_START);
	
	if y == 1 do strings.write_string(builder, "1;");
	else {
		strings.write_string(builder, strconv.itoa(buf[:], y));
		strings.write_rune_builder(builder, ';');
	}
	
	if x == 1 do strings.write_string(builder, "1H");
	else {
		strings.write_string(builder, strconv.itoa(buf[:], x));
		strings.write_rune_builder(builder, 'H');
	}
	
	return strings.to_string(builder^);
}

getSequence_moveup :: proc(amt: int, b: ^strings.Builder = nil) -> string {
	if amt == 1 {
		if b != nil {
			strings.write_string(b, MOVE_UP);
			return strings.to_string(b^);
		}
		return strings.clone(MOVE_UP);
	}
	
	builder_new: strings.Builder;
	builder: ^strings.Builder = b;
	if b == nil {
		// Create new builder for this sequence only if not
		// being added to a pre-existing builder.
		builder_new = strings.make_builder();
		builder = &builder_new;
	}
	
	strings.write_string(builder, SEQUENCE_START);
	
	buf: [129]byte;
	strings.write_string(builder, strconv.itoa(buf[:], amt));
	strings.write_rune_builder(builder, 'A');
	
	return strings.to_string(builder^);
}

getSequence_movedown :: proc(amt: int, b: ^strings.Builder = nil) -> string {
	if amt == 1 {
		if b != nil {
			strings.write_string(b, MOVE_DOWN);
			return strings.to_string(b^);
		}
		return strings.clone(MOVE_DOWN);
	}
	
	builder_new: strings.Builder;
	builder: ^strings.Builder = b;
	if b == nil {
		// Create new builder for this sequence only if not
		// being added to a pre-existing builder.
		builder_new = strings.make_builder();
		builder = &builder_new;
	}
	
	strings.write_string(builder, SEQUENCE_START);
	
	buf: [129]byte;
	strings.write_string(builder, strconv.itoa(buf[:], amt));
	strings.write_rune_builder(builder, 'B');
	
	return strings.to_string(builder^);
}

getSequence_moveleft :: proc(amt: int, b: ^strings.Builder = nil) -> string {
	if amt == 1 {
		if b != nil {
			strings.write_string(b, MOVE_LEFT);
			return strings.to_string(b^);
		}
		return strings.clone(MOVE_LEFT);
	}
	
	builder_new: strings.Builder;
	builder: ^strings.Builder = b;
	if b == nil {
		// Create new builder for this sequence only if not
		// being added to a pre-existing builder.
		builder_new = strings.make_builder();
		builder = &builder_new;
	}
	
	strings.write_string(builder, SEQUENCE_START);
	
	buf: [129]byte;
	strings.write_string(builder, strconv.itoa(buf[:], amt));
	strings.write_rune_builder(builder, 'D');
	
	return strings.to_string(builder^);
}

getSequence_moveright :: proc(amt: int, b: ^strings.Builder = nil) -> string {
	if amt == 1 {
		if b != nil {
			strings.write_string(b, MOVE_RIGHT);
			return strings.to_string(b^);
		}
		return strings.clone(MOVE_RIGHT);
	}
	
	builder_new: strings.Builder;
	builder: ^strings.Builder = b;
	if b == nil {
		// Create new builder for this sequence only if not
		// being added to a pre-existing builder.
		builder_new = strings.make_builder();
		builder = &builder_new;
	}
	
	strings.write_string(builder, SEQUENCE_START);
	
	buf: [129]byte;
	strings.write_string(builder, strconv.itoa(buf[:], amt));
	strings.write_rune_builder(builder, 'C');
	
	return strings.to_string(builder^);
}

setCursor_xy :: proc(x, y: int, cursor: ^CursorPos = nil, savePrev := false) {
	if savePrev {
		saveCursor();
	}

    str := getSequence_set(x, y);
    defer delete(str);
    os.write_string(os.stdout, str);
	
	if cursor != nil {
		cursor.x = x;
		cursor.y = y;
	}
}
setCursor_cursor :: proc(cursor: CursorPos, savePrev := false) {
	setCursor_xy(x = cursor.x, y = cursor.y, savePrev = savePrev);
}
setCursor :: proc{setCursor_xy, setCursor_cursor};

setCursor_topleft :: proc(cursor: ^CursorPos = nil, savePrev := false) {
	if savePrev {
		saveCursor();
	}
	
    os.write_string(os.stdout, TOP_LEFT);
	
	if cursor != nil {
		cursor.x = 1;
		cursor.y = 1;
	}
}

setCursor_topright :: proc(termSize: ^TermSize = nil, cursor: ^CursorPos = nil, savePrev := false) {
	if savePrev {
		saveCursor();
	}
	
	c := getCursor_topright(termSize);
	setCursor(c);
	if cursor != nil do cursor^ = c;
}

setCursor_bottomleft :: proc(termSize: ^TermSize = nil, cursor: ^CursorPos = nil, savePrev := false) {
	if savePrev {
		saveCursor();
	}
	
	c := getCursor_bottomleft(termSize);
	setCursor(c);
	if cursor != nil do cursor^ = c;
}

setCursor_bottomright :: proc(termSize: ^TermSize = nil, cursor: ^CursorPos = nil, savePrev := false) {
	if savePrev {
		saveCursor();
	}
	
	c := getCursor_bottomright(termSize);
	setCursor(c);
	if cursor != nil do cursor^ = c;
}

// TODO: Add optional cursor argument to be set
moveCursor_up :: proc(amt: int = 1) {
    str := getSequence_moveup(amt);
    defer delete(str);
    os.write_string(os.stdout, str);
}

moveCursor_down :: proc(amt: int = 1) {
    str := getSequence_movedown(amt);
    defer delete(str);
    os.write_string(os.stdout, str);
}

moveCursor_left :: proc(amt: int = 1) {
    str := getSequence_moveleft(amt);
    defer delete(str);
    os.write_string(os.stdout, str);
}

moveCursor_right :: proc(amt: int = 1) {
    str := getSequence_moveright(amt);
    defer delete(str);
    os.write_string(os.stdout, str);
}

moveCursor_start :: proc() {
    os.write_byte(os.stdout, '\r');
}

moveCursor_end :: proc(termSize: ^TermSize = nil) {
	new_ts: TermSize;
	moveCursor_start();
    new_ts = getTermSize();
    if termSize != nil do termSize^ = new_ts;
    str := getSequence_moveright(new_ts.width);
    os.write_string(os.stdout, str);
}

write_string_nocolor :: proc(s: string) {
    os.write_string(os.stdout, s);
}

write_string_at_nocolor :: proc(cursor: CursorPos, s: string) {
	saveCursor();
	setCursor(cursor);
	write_string_nocolor(s);
	restoreCursor();
}

write_string_color :: proc(fg: ForegroundColor, s: string) {
	setColor(fg);
    os.write_string(os.stdout, s);
	resetColors();
}

write_string_at_color :: proc(cursor: CursorPos, fg: ForegroundColor, s: string) {
	saveCursor();
	setCursor(cursor);
	write_string_color(fg, s);
	restoreCursor();
}

write_string :: proc{write_string_nocolor, write_string_color, write_string_at_nocolor, write_string_at_color};
// TODO: write_strings functions with ..string arg, but doesn't use print/printf/println

write_strings_nocolor :: proc(args: ..string) {
	for s in args {
		write_string(s);
	}
}

write_strings_at_nocolor :: proc(cursor: CursorPos, args: ..string) {
	saveCursor();
	setCursor(cursor);
	write_strings_nocolor(..args);
	restoreCursor();
}

write_strings_color :: proc(fg: ForegroundColor, args: ..string) {
	for s in args {
		write_string(fg, s);
	}
}

write_strings_at_color :: proc(cursor: CursorPos, fg: ForegroundColor, args: ..string) {
	saveCursor();
	setCursor(cursor);
	write_strings_color(fg, ..args);
	restoreCursor();
}

write_strings :: proc{write_strings_nocolor, write_strings_color, write_strings_at_nocolor, write_strings_at_color};

write_line_nocolor :: proc(s: string) {
    os.write_string(os.stdout, s);
	newLine();
}

write_line_at_nocolor :: proc(cursor: CursorPos, s: string) {
	saveCursor();
	setCursor(cursor);
	write_line_nocolor(s);
	restoreCursor();
}

write_line_color :: proc(fg: ForegroundColor, s: string) {
	setColor(fg);
    os.write_string(os.stdout, s);
	resetColors();
	newLine();
}

write_line_at_color :: proc(cursor: CursorPos, fg: ForegroundColor, s: string) {
	saveCursor();
	setCursor(cursor);
	write_line_color(fg, s);
	restoreCursor();
}

write_line :: proc{write_line_nocolor, write_line_color, write_line_at_nocolor, write_line_at_color};

write_byte_current :: proc(b: byte) {
    os.write_byte(os.stdout, b);
}

write_byte_at :: proc(cursor: CursorPos, b: byte) {
	saveCursor();
	setCursor(cursor);
	write_byte_current(b);
	restoreCursor();
}

write_byte :: proc{write_byte_current, write_byte_at};

write_rune_current :: proc(r: rune) {
    os.write_rune(os.stdout, r);
}

write_rune_at :: proc(cursor: CursorPos, r: rune) {
	saveCursor();
	setCursor(cursor);
	write_rune_current(r);
	restoreCursor();
}

write_rune :: proc{write_rune_current, write_rune_at};

// TODO: Not sure how to handle separator
print_nocolor :: proc(args: ..any, sep := " ") {
    fmt.print(..args);
}

print_at_nocolor :: proc(cursor: CursorPos, args: ..any, sep := " ") {
	saveCursor();
	setCursor(cursor);
	print_nocolor(..args);
	restoreCursor();
}

print_color :: proc(fg: ForegroundColor, args: ..any, sep := " ") {
	setColor(fg);
    fmt.print(..args);
	resetColors();
}

print_at_color :: proc(cursor: CursorPos, fg: ForegroundColor, args: ..any, sep := " ") {
	saveCursor();
	setCursor(cursor);
	print_color(fg, ..args);
	restoreCursor();
}

print :: proc{print_nocolor, print_color, print_at_nocolor, print_at_color};

println_nocolor :: proc(args: ..any, sep := " ") {
    fmt.println(..args);
}

println_at_nocolor :: proc(cursor: CursorPos, args: ..any, sep := " ") {
	saveCursor();
	setCursor(cursor);
	println_nocolor(..args);
	restoreCursor();
}

println_color :: proc(fg: ForegroundColor, args: ..any, sep := " ") {
	setColor(fg);
    fmt.println(..args);
	resetColors();
}

println_at_color :: proc(cursor: CursorPos, fg: ForegroundColor, args: ..any, sep := " ") {
	saveCursor();
	setCursor(cursor);
	println_color(fg, ..args);
	restoreCursor();
}

println :: proc{println_nocolor, println_color, println_at_nocolor, println_at_color};

printf_nocolor :: proc(format: string, args: ..any) {
    fmt.printf(format, ..args);
}

printf_at_nocolor :: proc(cursor: CursorPos, format: string, args: ..any) {
	saveCursor();
	setCursor(cursor);
	printf_nocolor(format, ..args);
	restoreCursor();
}

printf_color :: proc(fg: ForegroundColor, format: string, args: ..any) {
	setColor(fg);
    fmt.printf(format, ..args);
	resetColors();
}

printf_at_color :: proc(cursor: CursorPos, fg: ForegroundColor, format: string, args: ..any) {
	saveCursor();
	setCursor(cursor);
	printf_color(fg, format, ..args);
	restoreCursor();
}

printf :: proc{printf_nocolor, printf_color, printf_at_nocolor, printf_at_color};

newLine :: proc(amt: int = 1) {
    for i in 0..<amt {
        os.write_string(os.stdout, NEWLINE);
    }
}

clearScreen :: proc() {
    os.write_string(os.stdout, CLEAR);
}

clearLine :: proc() {
    os.write_string(os.stdout, CLEAR_LINE);
}

clearLine_right :: proc() {
    os.write_string(os.stdout, CLEAR_LINE_RIGHT);
}

clearLine_left :: proc() {
    os.write_string(os.stdout, CLEAR_LINE_LEFT);
}

backspace :: proc(amt := 1, clear := true) {
    moveCursor_left(amt);
    if clear do clearLine_right();
    else {
        for i in 0..<amt {
            os.write_string(os.stdout, " ");
        }
        moveCursor_left(amt);
    }
}
