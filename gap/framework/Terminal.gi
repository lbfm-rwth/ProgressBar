#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Terminal.gi
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##
##  This file is part of the ProgressBar package.
##
##  This file's authors include Friedrich Rober.
##
##  Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# ANSI Escape Sequences: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797

BindGlobal("PB_ResetTerminal", function()
	PB_Global.Terminal := rec(
		cursorVerticalPos := 1,
		cursorHorizontalPos := 1,
		usedLines := 1,
		screenWidth := SizeScreen()[1] - 1,
	);
end);

BindGlobal("PB_Print", function(msg)
	local pos;
	pos := PB_Global.Terminal.cursorHorizontalPos + Length(msg);
	# TODO: FIXME: deal with this without an error
	if pos > PB_Global.Terminal.screenWidth + 1 then
		Error("Trying to print more than the screen width allows to");
	fi;
	WriteAll(STDOut, msg);
	PB_Global.Terminal.cursorHorizontalPos := pos;
end);

BindGlobal("PB_PrintNewLine", function(args...)
	local n;
	n := 1;
	if Length(args) = 1 then
		n := args[1];
	fi;
	WriteAll(STDOut, Concatenation(ListWithIdenticalEntries(n, "\n"))); # create n new lines
	PB_Global.Terminal.cursorVerticalPos := PB_Global.Terminal.cursorVerticalPos + n;
end);

BindGlobal("PB_ResetStyleAndColor", function()
	WriteAll(STDOut, "\033[0m");
end);

BindGlobal("PB_SetStyle", function(mode)
	if mode = "default" then
		WriteAll(STDOut, "\033[22m\033[23m\033[24m\033[25m");
	elif mode = "bold" then
		WriteAll(STDOut, "\033[1m");
	elif mode = "dim" then
		WriteAll(STDOut, "\033[2m");
	elif mode = "italic" then
		WriteAll(STDOut, "\033[3m");
	elif mode = "underline" then
		WriteAll(STDOut, "\033[4m");
	elif mode = "blinking" then
		WriteAll(STDOut, "\033[5m");
	fi;
end);

BindGlobal("PB_SetForegroundColor", function(color)
	if color = "default" then
		WriteAll(STDOut, "\033[39m");
	elif color = "black" then
		WriteAll(STDOut, "\033[30m");
    elif color = "red" then
        WriteAll(STDOut, "\033[31m");
	elif color = "green" then
        WriteAll(STDOut, "\033[32m");
	elif color = "yellow" then
        WriteAll(STDOut, "\033[33m");
	elif color = "blue" then
        WriteAll(STDOut, "\033[34m");
	elif color = "magenta" then
        WriteAll(STDOut, "\033[35m");
	elif color = "cyan" then
        WriteAll(STDOut, "\033[36m");
	elif color = "white" then
        WriteAll(STDOut, "\033[37m");
	fi;
end);

BindGlobal("PB_SetBackgroundColor", function(color)
	if color = "default" then
		WriteAll(STDOut, "\033[49m");
	elif color = "black" then
		WriteAll(STDOut, "\033[40m");
    elif color = "red" then
        WriteAll(STDOut, "\033[41m");
	elif color = "green" then
        WriteAll(STDOut, "\033[42m");
	elif color = "yellow" then
        WriteAll(STDOut, "\033[43m");
	elif color = "blue" then
        WriteAll(STDOut, "\033[44m");
	elif color = "magenta" then
        WriteAll(STDOut, "\033[45m");
	elif color = "cyan" then
        WriteAll(STDOut, "\033[46m");
	elif color = "white" then
        WriteAll(STDOut, "\033[47m");
	fi;
end);

BindGlobal("PB_HideCursor", function()
	WriteAll(STDOut, "\033[?25l"); # hide cursor
end);

BindGlobal("PB_ShowCursor", function()
	WriteAll(STDOut, "\033[?25h"); # show cursor
end);

BindGlobal("PB_MoveCursorDown", function(move)
	local n;
	move := AbsInt(move);
	n := PB_Global.Terminal.cursorVerticalPos + move;
	if PB_Global.Terminal.usedLines < n then
		move := PB_Global.Terminal.usedLines - PB_Global.Terminal.cursorVerticalPos;
		WriteAll(STDOut, Concatenation("\033[", String(move), "B")); # move cursor down X lines
		PB_PrintNewLine(n - PB_Global.Terminal.usedLines);
		PB_Global.Terminal.usedLines := n;
	else
		WriteAll(STDOut, Concatenation("\033[", String(move), "B")); # move cursor down X lines
		PB_Global.Terminal.cursorVerticalPos := PB_Global.Terminal.cursorVerticalPos + move;
	fi;
end);

BindGlobal("PB_MoveCursorUp", function(move)
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "A")); # move cursor up X lines
	PB_Global.Terminal.cursorVerticalPos := PB_Global.Terminal.cursorVerticalPos - move;
end);

BindGlobal("PB_MoveCursorToLine", function(n)
	local move;
	move := n - PB_Global.Terminal.cursorVerticalPos;
	if move > 0 then
		PB_MoveCursorDown(move);
	elif move < 0 then
		PB_MoveCursorUp(-move);
	fi;
end);

BindGlobal("PB_MoveCursorRight", function(move)
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "C")); # move cursor right X characters
	PB_Global.Terminal.cursorHorizontalPos := PB_Global.Terminal.cursorHorizontalPos + move;
end);

BindGlobal("PB_MoveCursorLeft", function(move)
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "D")); # move cursor left X characters
	PB_Global.Terminal.cursorHorizontalPos := PB_Global.Terminal.cursorHorizontalPos - move;
end);

BindGlobal("PB_MoveCursorToChar", function(n)
	local move;
	move := n - PB_Global.Terminal.cursorHorizontalPos;
	if move > 0 then
		PB_MoveCursorRight(move);
	elif move < 0 then
		PB_MoveCursorLeft(-move);
	fi;
end);

BindGlobal("PB_MoveCursorToCoordinate", function(x, y)
	PB_MoveCursorToChar(x);
	PB_MoveCursorToLine(y);
end);

BindGlobal("PB_MoveCursorToStartOfLine", function()
	WriteAll(STDOut, "\r"); # move cursor to the start of the line
	PB_Global.Terminal.cursorHorizontalPos := 1;
end);

BindGlobal("PB_ClearLine", function()
	WriteAll(STDOut, "\033[2K"); # erase the entire line
end);

BindGlobal("PB_RefreshLine", function()
	PB_MoveCursorToStartOfLine();
	PB_ClearLine();
end);

BindGlobal("PB_ClearScreen", function()
	PB_MoveCursorToLine(PB_Global.Terminal.usedLines);
	PB_RefreshLine();
	while PB_Global.Terminal.cursorVerticalPos > 1 do
		PB_MoveCursorUp(1);
		PB_ClearLine();
	od;
end);

BindGlobal("PB_ClearBlock", function(block)
	local empty, j;
	empty := Concatenation(ListWithIdenticalEntries(block.w, " "));
	for j in [1 .. block.h] do
		PB_MoveCursorToCoordinate(block.x, block.y + j - 1);
		PB_Print(empty);
	od;
end);

BindGlobal("PB_ClearProcess", function(process)
	local block, j;
	if IsBound(process.blocks) then
		block := process.blocks.(PB_Global.ProgressPrinter.Layout.id);
		PB_MoveCursorToLine(block.y);
		PB_RefreshLine();
		for j in [2 .. block.h] do
			PB_MoveCursorDown(1);
			PB_ClearLine();
		od;
	fi;
end);
