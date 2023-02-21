package ncure_common

import "core:c"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:fmt"
foreign import libc "system:c"

@(private)
_batch :: false;

GET_CURSOR :: "\e[6n";

// -- termios stuff --
cc_t :: distinct c.uchar;
speed_t :: distinct c.uint;
tcflag_t :: distinct c.uint;

NCCS :: 32;
termios :: struct {
	c_iflag: tcflag_t,  // Input modes
	c_oflag: tcflag_t,  // Output modes
	c_cflag: tcflag_t,  // Control modes
	c_lflag: tcflag_t,  // Local modes
	c_line: cc_t,
	c_cc: [NCCS]cc_t,    // Special characters
	c_ispeed: speed_t,  // Input speed
	c_ospeed: speed_t,   // Output speed
}


/* c_cc characters */
VINTR :: 0;
VQUIT :: 1;
VERASE :: 2;
VKILL :: 3;
VEOF :: 4;
VTIME :: 5;
VMIN :: 6;
VSWTC :: 7;
VSTART :: 8;
VSTOP :: 9;
VSUSP :: 10;
VEOL :: 11;
VREPRINT :: 12;
VDISCARD :: 13;
VWERASE :: 14;
VLNEXT :: 15;
VEOL2 :: 16;

/* c_iflag bits */
IGNBRK: tcflag_t : 0000001;
BRKINT: tcflag_t : 0000002;
IGNPAR: tcflag_t : 0000004;
PARMRK: tcflag_t : 0000010;
INPCK: tcflag_t : 0000020;
ISTRIP: tcflag_t : 0000040;
INLCR: tcflag_t : 0000100;
IGNCR: tcflag_t : 0000200;
ICRNL: tcflag_t : 0000400;
IUCLC: tcflag_t : 0001000;
IXON: tcflag_t : 0002000;
IXANY: tcflag_t : 0004000;
IXOFF: tcflag_t : 0010000;
IMAXBEL :: 0020000;
IUTF8 :: 0040000;

/* c_oflag bits */
OPOST :: 0000001;
OLCUC :: 0000002;
ONLCR :: 0000004;
OCRNL :: 0000010;
ONOCR :: 0000020;
ONLRET :: 0000040;
OFILL :: 0000100;
OFDEL :: 0000200;
/*#if defined __USE_MISC || defined __USE_XOPEN
# define NLDLY        0000400
# define   NL0        0000000
# define   NL1        0000400
# define CRDLY        0003000
# define   CR0        0000000
# define   CR1        0001000
# define   CR2        0002000
# define   CR3        0003000
# define TABDLY        0014000
# define   TAB0        0000000
# define   TAB1        0004000
# define   TAB2        0010000
# define   TAB3        0014000
# define BSDLY        0020000
# define   BS0        0000000
# define   BS1        0020000
# define FFDLY        0100000
# define   FF0        0000000
# define   FF1        0100000
#endif*/
VTDLY :: 0040000;
VT0 :: 0000000;
VT1 :: 0040000;
/*#ifdef __USE_MISC
# define XTABS        0014000
#endif*/

/* c_cflag bit meaning */
/*#ifdef __USE_MISC
# define CBAUD        0010017
#endif*/
B0 :: 0000000;                /* hang up */
B50 :: 0000001;
B75 :: 0000002;
B110 :: 0000003;
B134 :: 0000004;
B150 :: 0000005;
B200 :: 0000006;
B300 :: 0000007;
B600 :: 0000010;
B1200 :: 0000011;
B1800 :: 0000012;
B2400 :: 0000013;
B4800 :: 0000014;
B9600 :: 0000015;
B19200 :: 0000016;
B38400 :: 0000017;
// #ifdef __USE_MISC
// # define EXTA B19200
// # define EXTB B38400
// #endif
CSIZE :: 0000060;
CS5 :: 0000000;
CS6 :: 0000020;
CS7 :: 0000040;
CS8 :: 0000060;
CSTOPB :: 0000100;
CREAD :: 0000200;
PARENB :: 0000400;
PARODD :: 0001000;
HUPCL :: 0002000;
CLOCAL :: 0004000;
// #ifdef __USE_MISC
// # define CBAUDEX 0010000
// #endif
B57600 :: 0010001;
B115200 :: 0010002;
B230400 :: 0010003;
B460800 :: 0010004;
B500000 :: 0010005;
B576000 :: 0010006;
B921600 :: 0010007;
B1000000 :: 0010010;
B1152000 :: 0010011;
B1500000 :: 0010012;
B2000000 :: 0010013;
B2500000 :: 0010014;
B3000000 :: 0010015;
B3500000 :: 0010016;
B4000000 :: 0010017;
__MAX_BAUD :: B4000000;
// #ifdef __USE_MISC
// # define CIBAUD          002003600000                /* input baud rate (not used) */
// # define CMSPAR   010000000000                /* mark or space (stick) parity */
// # define CRTSCTS  020000000000                /* flow control */
// #endif

/* c_lflag bits */
ISIG :: 0000001;
ICANON: tcflag_t : 0000002;
// #if defined __USE_MISC || (defined __USE_XOPEN && !defined __USE_XOPEN2K)
// # define XCASE        0000004
// #endif
ECHO: tcflag_t : 0000010;
ECHOE :: 0000020;
ECHOK :: 0000040;
ECHONL :: 0000100;
NOFLSH :: 0000200;
TOSTOP :: 0000400;
/*#ifdef __USE_MISC
# define ECHOCTL 0001000
# define ECHOPRT 0002000
# define ECHOKE         0004000
# define FLUSHO         0010000
# define PENDIN         0040000
#endif*/
IEXTEN :: 0100000;
/*#ifdef __USE_MISC
# define EXTPROC 0200000
#endif*/

TCSANOW :: 0;
TCSADRAIN :: 1;
TCSAFLUSH :: 2;

// -- ioctl --
winsize :: struct {
	ws_row: c.ushort,
	ws_col: c.ushort,
	ws_xpixel: c.ushort,
	ws_ypixel: c.ushort,
}

TIOCGWINSZ :: 21523;

foreign libc {
    @(link_name="tcgetattr") _unix_tcgetattr :: proc(fd: os.Handle, termios_p: ^termios) -> c.int ---;
    @(link_name="tcsetattr") _unix_tcsetattr :: proc(fd: os.Handle, optional_actions: c.int, termios_p: ^termios) -> c.int ---;
    @(link_name="ioctl") _unix_ioctl :: proc(fd: os.Handle, request: c.ulong, argp: rawptr) -> c.int ---;
}


tcgetattr :: proc(fd: os.Handle, termios_p: ^termios) -> os.Errno {
	result := _unix_tcgetattr(fd, termios_p);
	if result == -1 {
		return os.Errno(os.get_last_error());
	}
	
	return os.ERROR_NONE;
}

tcsetattr :: proc(fd: os.Handle, optional_actions: int, termios_p: ^termios) -> os.Errno {
	result := _unix_tcsetattr(fd, c.int(optional_actions), termios_p);
	if result == -1 {
		return os.Errno(os.get_last_error());
	}
	
	return os.ERROR_NONE;
}

ioctl :: proc(fd: os.Handle, request: u64, argp: rawptr) -> (int, os.Errno) {
	result := _unix_ioctl(fd, c.ulong(request), argp);
	if result == -1 {
		return -1, os.Errno(os.get_last_error());
	}
	
	return int(result), os.ERROR_NONE;
}

// ----- ncure stuff -----

NEWLINE :: "\n";

getTermSize :: proc() -> (termSize: TermSize) {
	w: winsize;
	if _, err := ioctl(os.stdout, TIOCGWINSZ, &w); err != os.ERROR_NONE {
		// Error
	}
	
	termSize.width = int(w.ws_col);
	termSize.height = int(w.ws_row);
	return termSize;
}

getCursor :: proc() -> CursorPos {
	cursor: CursorPos;
	
	// Disable Echo, send request, then switch terminal
	// back to previous settings
    // TODO: Make this part OS-agnostic so getCursor can be moved back into vt100 package
	prev, _ := disableEcho(false);
	os.write_string(os.stdout, GET_CURSOR);
	if set_error := tcsetattr(os.stdin, TCSANOW, &prev); set_error != os.ERROR_NONE {
		fmt.println("Error setting terminal info: %s\n", set_error);
	}
	
	// Get response
	response := strings.builder_make();
	defer strings.builder_destroy(&response);
	data: byte;
	for {
		data = getch();
		
		strings.write_byte(&response, data);
		if data == 'R' do break;
	}
	
	// Parse response
	response_str := strings.to_string(response);
	arg1_start: int;
	arg1_end: int;
	arg2_start: int;
	arg2_end: int;
	for c, i in response_str {
		if c == '[' do arg1_start = i + 1;
		if c == ';' {
			arg1_end = i;
			arg2_start = i + 1;
		}
		if c == 'R' {
			arg2_end = i;
		}
	}
	
	arg1 := response_str[arg1_start:arg1_end];
	arg2 := response_str[arg2_start:arg2_end];
	
	cursor.y = strconv.atoi(arg1);
	cursor.x = strconv.atoi(arg2);
	
	return cursor;
}
