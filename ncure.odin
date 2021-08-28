package ncure

import "core:os"
import "core:fmt"
import "common"

when ODIN_OS == "windows" {
	import "core:sys/windows"
}

TermSize :: common.TermSize;
CursorPos :: common.CursorPos;

write_string_nocolor :: proc(s: string) {
    os.write_string(os.stdout, s);
}

write_string_at_nocolor :: proc(cursor: CursorPos, s: string) {
	when ODIN_OS == "windows" {
		if !_ansiMode {
			utf16str := windows.utf8_to_utf16(s, context.temp_allocator);
			defer delete(utf16str, context.temp_allocator);

			charsWritten: windows.DWORD;
			newWritePos_start: COORD = { i16(cursor.x) - 1, i16(cursor.y) - 1 };

			// consoleInfo: common.CONSOLE_SCREEN_BUFFER_INFO;
			// common.GetConsoleScreenBufferInfo(hConsole^, consoleInfo);

			i: i16 = 0;
			for c in utf16str {
				pos := common.COORD { newWritePos_start.X + i, newWritePos_start.Y };
				common.FillConsoleOutputCharacterW(hConsole^, c, 1, pos, &charsWritten); // TODO: Check if failed?
				// common.FillConsoleOutputAttribute(hConsole^, consoleInfo.wAttributes, 1, pos, &charsWritten);
				i += 1;
			}
			return;
		}
	}

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
	when ODIN_OS == "windows" {
		if !_ansiMode {
			utf16str := windows.utf8_to_utf16(s, context.temp_allocator);
			defer delete(utf16str, context.temp_allocator);

			color := common._colorToAttribute_foreground(fg);
			charsWritten: windows.DWORD;
			newWritePos_start: COORD = { i16(cursor.x) - 1, i16(cursor.y) - 1 };

			//consoleInfo: common.CONSOLE_SCREEN_BUFFER_INFO;
			//common.GetConsoleScreenBufferInfo(hConsole^, consoleInfo);

			i: i16 = 0;
			for c in utf16str {
				pos := common.COORD { newWritePos_start.X + i, newWritePos_start.Y };
				FillConsoleOutputCharacterW(hConsole^, c, 1, pos, &charsWritten); // TODO: Check if failed?
				FillConsoleOutputAttribute(hConsole^, color, 1, pos, &charsWritten);
				i += 1;
			}
			return;
		}
	}

	saveCursor();
	setCursor(cursor);
	write_string_color(fg, s);
	restoreCursor();
}

write_string :: proc{write_string_nocolor, write_string_color, write_string_at_nocolor, write_string_at_color};

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

write_rune_at :: proc(cursor: CursorPos, r: rune) { // TODO
	saveCursor();
	setCursor(cursor);
	write_rune_current(r);
	restoreCursor();
}

write_rune :: proc{write_rune_current, write_rune_at};

print_nocolor :: proc(args: ..any, sep := " ") {
    fmt.print(args = args, sep = sep);
}

print_at_nocolor :: proc(cursor: CursorPos, args: ..any, sep := " ") {
	saveCursor();
	setCursor(cursor);
	print_nocolor(..args); // TODO
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
