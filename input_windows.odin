package ncure

import "core:os"
import "core:fmt"

Input :: enum i32 {
	CTRL_C = 3,
	CTRL_L = 12,
	CTRL_O = 15,
	CTRL_X = 24,
	ESC = 27,
	BACKSPACE = '\b', // TODO
	ENTER = 10,

	SPECIAL1 = -32, // TODO
	SPECIAL2 = 224,

	LEFT = 75,
	UP = 76,
	RIGHT = 77,
	DOWN = 78,
	DELETE = 83,
	END = 79,
	HOME = 71,
	ENDINPUT = 26, // Ctrl+Z
	CTRL_BACKSPACE = 8,
}

isSpecial :: proc(c: byte) -> bool {
	if cast(i32) c == cast(i32) Input.SPECIAL1 || cast(i32) c == cast(i32) Input.SPECIAL2 {
		return true;
	}

	return false;
}


disableEcho :: proc(nonblocking := false) {
	/*if get_error := linux.tcgetattr(os.stdin, &prev); get_error != os.ERROR_NONE {
		// Error
		fmt.println("Error getting terminal info: %s\n", get_error);
	}

	current = prev;
	current.c_lflag &= ~linux.ICANON;
	current.c_lflag &= ~linux.ECHO;
	if nonblocking do current.c_cc[linux.VMIN] = 0;
	else do current.c_cc[linux.VMIN] = 1;
	current.c_cc[linux.VTIME] = 0;

	if set_error := linux.tcsetattr(os.stdin, linux.TCSANOW, &current); set_error != os.ERROR_NONE {
		fmt.println("Error setting terminal info: %s\n", set_error);
	}

	return prev, current;*/
}

enableEcho :: proc() {
	/*term: linux.termios;
	if get_error := linux.tcgetattr(os.stdin, &term); get_error != os.ERROR_NONE {
		// Error
		fmt.println("Error getting terminal info: %s\n", get_error);
	}

	term.c_lflag |= linux.ICANON;
	term.c_lflag |= linux.ECHO;

	if set_error := linux.tcsetattr(os.stdin, linux.TCSANOW, &term); set_error != os.ERROR_NONE {
		fmt.println("Error setting terminal info: %s\n", set_error);
	}*/
}

enableBlocking :: proc() {
	/*term: linux.termios;
	if get_error := linux.tcgetattr(os.stdin, &term); get_error != os.ERROR_NONE {
		// Error
		fmt.println("Error getting terminal info: %s\n", get_error);
	}

	term.c_cc[linux.VMIN] = 1;
	term.c_cc[linux.VTIME] = 0;

	if set_error := linux.tcsetattr(os.stdin, linux.TCSANOW, &term); set_error != os.ERROR_NONE {
		fmt.println("Error setting terminal info: %s\n", set_error);
	}*/
}

disableBlocking :: proc() {
	/*term: linux.termios;
	if get_error := linux.tcgetattr(os.stdin, &term); get_error != os.ERROR_NONE {
		// Error
		fmt.println("Error getting terminal info: %s\n", get_error);
	}

	term.c_cc[linux.VMIN] = 0;
	term.c_cc[linux.VTIME] = 0;

	if set_error := linux.tcsetattr(os.stdin, linux.TCSANOW, &term); set_error != os.ERROR_NONE {
		fmt.println("Error setting terminal info: %s\n", set_error);
	}*/
}

getch :: proc() -> (byte) {
	data: [1]byte;
	if bytes_read, _ := os.read(os.stdin, data[:]); bytes_read < 0 {
		fmt.println("Error reading Input");
	}
	return data[0];
}
