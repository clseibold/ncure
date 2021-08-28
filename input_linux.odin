package ncure

import "core:fmt"
import "core:os"
when ODIN_OS == "linux" { import "../linux" }

Input :: enum u8 {
	CTRL_C = 3,
	CTRL_D = 4,
	END_INPUT = 4,
	CTRL_BACKSPACE = 8,
	ENTER = 10,
	CTRL_L = 12,
	CTRL_O = 15,
	CTRL_X = 24,
	CTRL_Z = 26,
	ESC = 27,

	SPECIAL1 = 27,
	SPECIAL2 = 91,
	LEFT = 68,
	RIGHT = 67,
	UP = 65,
	DOWN = 66,
	DELETE1 = 51,
	DELETE2 = 126,
	END = 70,
	HOME = 72,
	BACKSPACE = 127
}

isSpecial :: proc(c: byte) -> bool {
	if Input(c) == Input.SPECIAL1 {
		next := getch();
		if Input(next) == Input.SPECIAL2 {
			return true;
		} else {
			// TODO
		}
	}

	return false;
}

disableEcho :: proc(nonblocking := false) -> (prev: linux.termios, current: linux.termios) {
	if get_error := linux.tcgetattr(os.stdin, &prev); get_error != os.ERROR_NONE {
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

	return prev, current;
}

enableEcho :: proc() {
	term: linux.termios;
	if get_error := linux.tcgetattr(os.stdin, &term); get_error != os.ERROR_NONE {
		// Error
		fmt.println("Error getting terminal info: %s\n", get_error);
	}

	term.c_lflag |= linux.ICANON;
	term.c_lflag |= linux.ECHO;

	if set_error := linux.tcsetattr(os.stdin, linux.TCSANOW, &term); set_error != os.ERROR_NONE {
		fmt.println("Error setting terminal info: %s\n", set_error);
	}
}

enableBlocking :: proc() {
	term: linux.termios;
	if get_error := linux.tcgetattr(os.stdin, &term); get_error != os.ERROR_NONE {
		// Error
		fmt.println("Error getting terminal info: %s\n", get_error);
	}

	term.c_cc[linux.VMIN] = 1;
	term.c_cc[linux.VTIME] = 0;

	if set_error := linux.tcsetattr(os.stdin, linux.TCSANOW, &term); set_error != os.ERROR_NONE {
		fmt.println("Error setting terminal info: %s\n", set_error);
	}
}

disableBlocking :: proc() {
	term: linux.termios;
	if get_error := linux.tcgetattr(os.stdin, &term); get_error != os.ERROR_NONE {
		// Error
		fmt.println("Error getting terminal info: %s\n", get_error);
	}

	term.c_cc[linux.VMIN] = 0;
	term.c_cc[linux.VTIME] = 0;

	if set_error := linux.tcsetattr(os.stdin, linux.TCSANOW, &term); set_error != os.ERROR_NONE {
		fmt.println("Error setting terminal info: %s\n", set_error);
	}
}

getch :: proc() -> (byte) {
	data: [1]byte;
	if bytes_read, _ := os.read(os.stdin, data[:]); bytes_read < 0 {
		fmt.println("Error reading Input");
	}
	return data[0];
}


