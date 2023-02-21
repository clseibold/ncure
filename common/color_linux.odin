package ncure_common

import "core:os"
import "core:strings"
import "core:strconv"
//import "common"

//SEQUENCE_START :: common.SEQUENCE_START;
SEQUENCE_START :: "\e[";
RESET_COLORS :: "\e[0m"; // TODO: \e[39;49m

setColor_foreground :: proc(fg: ForegroundColor) {
	new_builder: strings.Builder;
	b: ^strings.Builder;
	new_builder = strings.builder_make(0, len(SEQUENCE_START));
	b = &new_builder;
	
	strings.write_string(b, SEQUENCE_START); // ESC[
	buf: [129]byte;
	strings.write_string(b, strconv.itoa(buf[:], int(fg)));
	strings.write_rune(b, 'm');
	
	if !_batch {
		os.write_string(os.stdout, strings.to_string(b^));
		strings.builder_destroy(b);
	}
}

setColor_background :: proc(bg: BackgroundColor) {
	new_builder: strings.Builder;
	b: ^strings.Builder;
	new_builder = strings.builder_make(0, len(SEQUENCE_START));
	b = &new_builder;
	
	strings.write_string(b, SEQUENCE_START); // ESC[
	buf: [129]byte;
	strings.write_string(b, strconv.itoa(buf[:], int(bg)));
	strings.write_rune(b, 'm');
	
	if !_batch {
		os.write_string(os.stdout, strings.to_string(b^));
		strings.builder_destroy(b);
	}
}

setColor_fg_bg :: proc(fg: ForegroundColor, bg: BackgroundColor) {
	new_builder: strings.Builder;
	b: ^strings.Builder;
	new_builder = strings.builder_make(0, len(SEQUENCE_START));
	b = &new_builder;
	
	strings.write_string(b, SEQUENCE_START); // ESC[
	buf: [129]byte;
	strings.write_string(b, strconv.itoa(buf[:], int(fg)));
	strings.write_rune(b, ';');
	strings.write_string(b, strconv.itoa(buf[:], int(bg)));
	strings.write_rune(b, 'm');
	
	if !_batch {
		os.write_string(os.stdout, strings.to_string(b^));
		strings.builder_destroy(b);
	}
}

setColor :: proc{setColor_foreground, setColor_background, setColor_fg_bg};

resetColors :: proc() {
	os.write_string(os.stdout, RESET_COLORS);
}

