//+build ignore
package main

import ncure ".."
import "core:strconv"
import "core:time"
import "core:fmt"

main :: proc() {
	ncure.initializeTerminal();
	ncure.enableVT100Mode();

	ncure.disableEcho(false);
	defer ncure.enableEcho();

	itoa_buf: [129]byte;
	termSize := ncure.getTermSize();

	{
		ncure.clearScreen();
		ncure.setCursor_topleft();
		ncure.printf(ncure.ForegroundColor.Magenta, "Current Terminal Size: (%d, %d)", termSize.width, termSize.height);

		ncure.setCursor_topright();
		str_topRight := "Hello!";
		ncure.moveCursor_left(len(str_topRight));
		ncure.write_string(str_topRight);

		ncure.setCursor(5, 4);
		ncure.write_string(ncure.ForegroundColor.Cyan, "Set cursor to (5, 4)");
		ncure.moveCursor_down();
		ncure.moveCursor_right(2);
		ncure.write_string(ncure.ForegroundColor.Red, "Gone down one and right two!");
		ncure.moveCursor_up(2);
		ncure.write_string(ncure.ForegroundColor.Red, "Gone up two lines!");
		ncure.moveCursor_down(3);
		ncure.moveCursor_start();
		ncure.write_string(ncure.ForegroundColor.Green, "Down 3 and Back at start!");

		ncure.moveCursor_down();
	}

	pos := ncure.getCursor();
	{
		ncure.write_strings(ncure.ForegroundColor.Blue, "Cursor pos at start of this text: (", strconv.itoa(itoa_buf[:], pos.x), ", ", strconv.itoa(itoa_buf[:], pos.y), ")");
		ncure.newLine();

		ncure.moveCursor_end();
		ncure.write_string("Cursor moved to end of line. Blahhhhh");
		ncure.moveCursor_left(8);
		ncure.clearLine_right();
		ncure.newLine();
		ncure.write_rune('x');
		ncure.newLine();
	}

	pos = ncure.getCursor();
	{
		ncure.setCursor_bottomleft();
		ncure.write_string("Testing bottom left");
		ncure.setCursor_bottomright();
		str_bottomRight := "Testing bottom right";
		ncure.moveCursor_left(len(str_bottomRight));
		ncure.write_string(str_bottomRight);

		ncure.setCursor(pos);

		ncure.write_string(ncure.ForegroundColor.Green, "Going back to saved cursor position");
		ncure.newLine();
	}

	// Progress bar test
	termSize = ncure.getTermSize();
	progressBar1(termSize);
	progressBar2(termSize);

	ncure.showCursor();
}


progressBar1 :: proc(termSize: ncure.TermSize) {
	ncure.hideCursor();
	division := 10;

	ncure.moveCursor_right((termSize.width / division) + 1);
	ncure.write_string("|");
	ncure.moveCursor_start();
	ncure.write_string("|");

	for i in 0..<(termSize.width / division) {
		ncure.write_string(ncure.ForegroundColor.Cyan, "=");

		time.sleep(1 * time.Second);
	}
	ncure.newLine();
}

progressBar2 :: proc(termSize: ncure.TermSize) {
	ncure.hideCursor();
	division := 10;

	progressBarWidth := (termSize.width / division) + 1;
	startPos := ncure.getCursor();
	endPos := ncure.CursorPos { progressBarWidth + 1, startPos.y };

	ncure.write_byte('|'); // start
	ncure.write_string(ncure.ForegroundColor.Cyan, "=");
	ncure.write_string(endPos, "|");
	time.sleep(1 * time.Second);

	for i in 1..<(termSize.width / division) {
		ncure.moveCursor_left();
		ncure.write_byte(' ');
		ncure.write_string(ncure.ForegroundColor.Cyan, "=");

		time.sleep(1 * time.Second);
	}
	ncure.newLine();
}
