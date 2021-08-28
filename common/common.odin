package ncure_common

TermSize :: struct {
	width: int,
	height: int,
}

CursorPos :: [2]int;

// TODO: Implement 256 colors, and perhaps true 24-bit colors
ForegroundColor :: enum u8 {
	Red = 31,
	BrightRed = 91,
	Green = 32,
	BrightGreen = 92,
	Blue = 34,
	BrightBlue = 94,

	Yellow = 33,
	BrightYellow = 93,
	Cyan = 36,
	BrightCyan = 96,
	Magenta = 35,
	BrightMagenta = 95,

	White = 37,
	BrightWhite = 97,
	Black = 30,
	Grey = 90,
}

BackgroundColor :: enum u8 {
	Red = 41,
	BrightRed = 101,
	Green = 42,
	BrightGreen = 102,
	Blue = 44,
	BrightBlue = 104,

	Yellow = 43,
	BrightYellow = 103,
	Cyan = 46,
	BrightCyan = 106,
	Magenta = 45,
	BrightMagenta = 105,

	White = 47,
	BrightWhite = 107,
	Black = 40,
	Grey = 100,
}
