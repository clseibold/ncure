//+build ignore
package main

import ncure ".."
import "core:strings"
import "core:container"

InputData :: struct {
    prompt: string,
    running: bool,
    inputHistory: container.Queue(string),
    history_index: int,
    cursorPos: int,
}
createInputData :: proc(inputData: ^InputData) {
    container.queue_init(&inputData.inputHistory, 0, 5);
    inputData.history_index = 0;
    inputData.cursorPos = 0;
}

main :: proc() {
    ncure.initializeTerminal();
    ncure.enableVT100Mode();
    ncure.disableEcho();
    defer ncure.enableEcho();

    input := strings.make_builder();
	defer strings.destroy_builder(&input);

    inputData: InputData;
    createInputData(&inputData);
    setPrompt("Enter a string: ", &inputData);
    cliInput(&input, &inputData);

    ncure.printf("\n%s", strings.to_string(input));
}

setPrompt :: proc(prompt: string, inputData: ^InputData) {
    inputData.prompt = prompt;
}

// NOTE: Doesn't currently support any unicode. ASCII only.
cliInput :: proc(input: ^strings.Builder, inputData: ^InputData) {
    printPrompt(inputData);
    strings.reset_builder(input);
    data: byte;
    for {
        data = ncure.getch();
        
        if ncure.Input(data) == ncure.Input.CTRL_C {
            inputData.running = false;
            strings.reset_builder(input);
            break;
        } else if ncure.Input(data) == ncure.Input.BACKSPACE {
            if len(input.buf) <= 0 do continue;
            
            if inputData.cursorPos < strings.builder_len(input^) {
                prev_before := string(input.buf[:inputData.cursorPos - 1]);
                //prev_after := strings.clone(string(input.buf[inputData.cursorPos:]), context.temp_allocator);
                prev_after := string(input.buf[inputData.cursorPos:]);
                strings.reset_builder(input);
                strings.write_string(input, prev_before);
                strings.write_string(input, prev_after);
                inputData.cursorPos -= 1;

                // Print rest of string
                ncure.moveCursor_left();
                ncure.clearLine_right();
                ncure.write_string(string(input.buf[inputData.cursorPos:]));
                // Move cursor back to cursor position
                ncure.moveCursor_left(strings.builder_len(input^) - inputData.cursorPos);
            } else {
                strings.pop_rune(input);
                ncure.backspace();
            }
            continue;
        } else if ncure.Input(data) == ncure.Input.ENTER {
            inputData.history_index = 0;
            break;
        } else if ncure.Input(data) == ncure.Input.CTRL_BACKSPACE {
            if len(input.buf) <= 0 do continue;
            
            // Search for whitespace before cursor
            last_whitespace_index := strings.last_index(string(input.buf[:inputData.cursorPos]), " ");
            rune_count := strings.rune_count(string(input.buf[:inputData.cursorPos]));
            if last_whitespace_index == -1 { // TODO
                /*strings.reset_builder(input);
                ncure.moveCursor_left(rune_count);
                ncure.clearLine_right();
                continue;*/
                last_whitespace_index = 0;
            }

            // Delete stuff from builder
            prev_before := string(input.buf[:last_whitespace_index]);
            prev_after := string(input.buf[inputData.cursorPos:]);
            strings.reset_builder(input);
            strings.write_string(input, prev_before);
            strings.write_string(input, prev_after);

            num_to_delete := inputData.cursorPos - last_whitespace_index;
            inputData.cursorPos -= num_to_delete;
            ncure.moveCursor_left(num_to_delete);
            ncure.clearLine_right();
            if strings.builder_len(input^) > 0 {
                ncure.write_string(string(input.buf[inputData.cursorPos:]));
                // move cursor back to location it was at
                ncure.moveCursor_left(strings.builder_len(input^) - inputData.cursorPos);
            }

            /*for i in 0..<num_to_delete {
                strings.pop_rune(input);
            }*/
            continue;
        } else if ncure.Input(data) == ncure.Input.CTRL_L {
            ncure.clearScreen();
            ncure.setCursor_topleft();
            printPrompt(inputData);
            ncure.write_string(string(input.buf[:]));
            // move cursor back to location it was at
            ncure.moveCursor_left(strings.builder_len(input^) - inputData.cursorPos);

            continue;
        } else if ncure.isSpecial(data) {
            data = ncure.getch();
            
            handleHistory :: proc(input: ^strings.Builder, using inputData: ^InputData) {
                old_rune_count := strings.rune_count(string(input.buf[:]));
                
                if history_index > 0 && history_index <= container.queue_len(inputHistory) {
                    hist_str := container.queue_get(inputHistory, container.queue_len(inputHistory) - (history_index));
                    strings.reset_builder(input);
                    strings.write_string(input, hist_str);
                    ncure.backspace(old_rune_count);
                    ncure.write_string(string(input.buf[:]));
                } else if history_index <= 0 {
                    strings.reset_builder(input);
                    ncure.backspace(old_rune_count);
                }
            }
            
            if data == 0x1D { // NOTE: Hack for Konsole
                data = ncure.getch();
            }
            if ncure.Input(data) == ncure.Input.UP {
                if inputData.history_index < container.queue_len(inputData.inputHistory) {
                    // Move cursor to end first
                    prevCursor := inputData.cursorPos;
                    inputData.cursorPos = strings.builder_len(input^);
                    ncure.moveCursor_right(inputData.cursorPos - prevCursor);

                    inputData.history_index += 1;
                    handleHistory(input, inputData);
                }
            } else if ncure.Input(data) == ncure.Input.DOWN {
                if inputData.history_index != 0 {
                    // Move cursor to end first
                    prevCursor := inputData.cursorPos;
                    inputData.cursorPos = strings.builder_len(input^);
                    ncure.moveCursor_right(inputData.cursorPos - prevCursor);

                    inputData.history_index -= 1;
                    handleHistory(input, inputData);
                }
            } else if ncure.Input(data) == ncure.Input.LEFT {
                if inputData.cursorPos > 0 {
                    ncure.moveCursor_left();
                    inputData.cursorPos -= 1;
                }
            } else if ncure.Input(data) == ncure.Input.RIGHT {
                if inputData.cursorPos < strings.builder_len(input^) {
                    ncure.moveCursor_right();
                    inputData.cursorPos += 1;
                }
            }

            if ncure.Input(data) == ncure.Input.HOME {
                prevCursor := inputData.cursorPos;
                inputData.cursorPos = 0;
                ncure.moveCursor_left(prevCursor);
            } else if ncure.Input(data) == ncure.Input.END {
                prevCursor := inputData.cursorPos;
                inputData.cursorPos = strings.builder_len(input^);
                ncure.moveCursor_right(inputData.cursorPos - prevCursor);
            } else if ncure.Input(data) == ncure.Input.DELETE {
                // TODO: There's a bug when pressing Delete on first character in a single character buffer - the cursor will move back one when it shouldn't.
                if len(input.buf) <= 0 || inputData.cursorPos >= strings.builder_len(input^) do continue;

                prev_before := string(input.buf[:inputData.cursorPos]);
                //prev_after := strings.clone(string(input.buf[inputData.cursorPos:]), context.temp_allocator);
                prev_after := string(input.buf[inputData.cursorPos + 1:]);
                strings.reset_builder(input);
                strings.write_string(input, prev_before);
                strings.write_string(input, prev_after);

                // Print rest of string
                ncure.clearLine_right();
                ncure.write_string(string(input.buf[inputData.cursorPos:]));
                // Move cursor back to cursor position
                ncure.moveCursor_left(strings.builder_len(input^) - inputData.cursorPos);
            }
            continue;
        } else if data >= 32 && data <= 126 {
            if inputData.cursorPos < strings.builder_len(input^) {
                prev_before := string(input.buf[:inputData.cursorPos]);
                prev_after := strings.clone(string(input.buf[inputData.cursorPos:]), context.temp_allocator);
                strings.reset_builder(input);
                strings.write_string(input, prev_before);
                strings.write_byte(input, data);
                strings.write_string(input, prev_after);
                inputData.cursorPos += 1;

                // Print rest of string
                ncure.write_string(string(input.buf[inputData.cursorPos - 1:]));
                // Move cursor back to cursor position
                ncure.moveCursor_left(strings.builder_len(input^) - inputData.cursorPos);
            } else {
                ncure.write_byte(data);
                strings.write_byte(input, data);
                inputData.cursorPos += 1;
            }
        }
    }
}

printPrompt :: proc(inputData: ^InputData) {
    ncure.printf("%s", inputData.prompt);
}
