package ncure

import "common"
import "vt100"

initializeTerminal :: proc() {
}

NEWLINE :: common.NEWLINE;
getTermSize :: common.getTermSize;
getCursor :: common.getCursor;
reset :: vt100.reset;

getCursor_topleft :: vt100.getCursor_topleft;
getCursor_topright :: vt100.getCursor_topright;
getCursor_bottomleft :: vt100.getCursor_bottomleft;
getCursor_bottomright :: vt100.getCursor_bottomright;

hideCursor :: vt100.hideCursor;
showCursor :: vt100.showCursor;
saveCursor :: vt100.saveCursor;
restoreCursor :: vt100.restoreCursor;
save_restore :: vt100.save_restore;

enableCursorBlinking :: vt100.enableCursorBlinking;
disableCursorBlinking :: vt100.disableCursorBlinking;

setCursor_xy :: vt100.setCursor_xy;
setCursor_cursor :: vt100.setCursor_cursor;
setCursor :: vt100.setCursor;
setCursor_topleft :: vt100.setCursor_topleft;
setCursor_topright :: vt100.setCursor_topright;
setCursor_bottomleft :: vt100.setCursor_bottomleft;
setCursor_bottomright :: vt100.setCursor_bottomright;

moveCursor_up :: vt100.moveCursor_up;
moveCursor_down :: vt100.moveCursor_down;
moveCursor_left :: vt100.moveCursor_left;
moveCursor_right :: vt100.moveCursor_right;
moveCursor_start :: vt100.moveCursor_start;
moveCursor_end :: vt100.moveCursor_end;

/*
write_string_nocolor :: vt100.write_string_nocolor;
write_string_at_nocolor :: vt100.write_string_at_nocolor;
write_string_color :: vt100.write_string_color;
write_string_at_color :: vt100.write_string_at_color;
write_string :: vt100.write_string;

write_strings_nocolor :: vt100.write_strings_nocolor;
write_strings_at_nocolor :: vt100.write_strings_at_nocolor;
write_strings_color :: vt100.write_strings_color;
write_strings_at_color :: vt100.write_strings_at_color;
write_strings :: vt100.write_strings;

write_line_nocolor :: vt100.write_line_nocolor;
write_line_at_nocolor :: vt100.write_line_at_nocolor;
write_line_color :: vt100.write_line_color;
write_line_at_color :: vt100.write_line_at_color;
write_line :: vt100.write_line;

write_byte_current :: vt100.write_byte_current;
write_byte_at :: vt100.write_byte_at;
write_byte :: vt100.write_byte;

write_rune_current :: vt100.write_rune_current;
write_rune_at :: vt100.write_rune_at;
write_rune :: vt100.write_rune;

print_nocolor :: vt100.print_nocolor;
print_at_nocolor :: vt100.print_at_nocolor;
print_color :: vt100.print_color;
print_at_color :: vt100.print_at_color;
print :: vt100.print;

println_nocolor :: vt100.println_nocolor;
println_at_nocolor :: vt100.println_at_nocolor;
println_color :: vt100.println_color;
println_at_color :: vt100.println_at_color;
println :: vt100.println;

printf_nocolor :: vt100.printf_nocolor;
printf_at_nocolor :: vt100.printf_at_nocolor;
printf_color :: vt100.printf_color;
printf_at_color :: vt100.printf_at_color;
printf :: vt100.printf;

newLine :: vt100.newLine;*/

clearScreen :: vt100.clearScreen;
clearLine :: vt100.clearLine;
clearLine_right :: vt100.clearLine_right;
clearLine_left :: vt100.clearLine_left;
backspace :: vt100.backspace;


enableAnsiMode :: proc() {}
enableVT100Mode :: enableAnsiMode;
disableAnsiMode :: proc() {}
disableVT100Mode :: disableAnsiMode;
setAnsiMode :: proc(on: bool) {}
setVT100Mode :: setAnsiMode;
