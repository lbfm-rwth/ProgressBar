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

InstallGlobalFunction("PB_Print", function(msg)
	local pos;
	if not ProgressPrinter.IsActive then
		return;
	fi;
	pos := ProgressPrinter.Cursor.x + Length(msg);
	if pos > ProgressPrinter.Dimensions.w + 1 then
		# Error("Trying to print more than the screen width allows to");
		return;
	fi;
	WriteAll(STDOut, msg);
	ProgressPrinter.Cursor.x := pos;
end);

InstallGlobalFunction("PB_SetStyleAndColor", function(r)
	if not ProgressPrinter.IsActive then
		return;
	fi;
	PB_SetStyle(r.style);
	PB_SetForegroundColor(r.foregroundColor);
	PB_SetBackgroundColor(r.backgroundColor);
end);

InstallGlobalFunction("PB_ResetStyleAndColor", function()
	if not ProgressPrinter.IsActive then
		return;
	fi;
	WriteAll(STDOut, "\033[0m");
end);

InstallGlobalFunction("PB_SetStyle", function(mode)
	if not ProgressPrinter.IsActive then
		return;
	fi;
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

InstallGlobalFunction("PB_SetForegroundColor", function(color)
	if not ProgressPrinter.IsActive then
		return;
	fi;
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

InstallGlobalFunction("PB_SetBackgroundColor", function(color)
	if not ProgressPrinter.IsActive then
		return;
	fi;
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

InstallGlobalFunction("PB_HideCursor", function()
	if not ProgressPrinter.IsActive then
		return;
	fi;
	WriteAll(STDOut, "\033[?25l"); # hide cursor
end);

InstallGlobalFunction("PB_ShowCursor", function()
	if not ProgressPrinter.IsActive then
		return;
	fi;
	WriteAll(STDOut, "\033[?25h"); # show cursor
end);

InstallGlobalFunction("PB_MoveCursorDown", function(move)
	local n, m, x;
	if not ProgressPrinter.IsActive then
		return;
	fi;
	move := AbsInt(move);
	n := ProgressPrinter.Cursor.y + move;
	if ProgressPrinter.Dimensions.h < n then
		move := ProgressPrinter.Dimensions.h - ProgressPrinter.Cursor.y;
		WriteAll(STDOut, Concatenation("\033[", String(move), "B")); # move cursor down X lines
		m := n - ProgressPrinter.Dimensions.h;
		x := ProgressPrinter.Cursor.x;
		PB_MoveCursorToStartOfLine();
		WriteAll(STDOut, Concatenation(ListWithIdenticalEntries(m, "\n"))); # create X new lines and move cursor to start of last line
		PB_RefreshLine();
		ProgressPrinter.Dimensions.h := n;
		PB_MoveCursorToChar(x);
	else
		WriteAll(STDOut, Concatenation("\033[", String(move), "B")); # move cursor down X lines
	fi;
	ProgressPrinter.Cursor.y := n;
end);

InstallGlobalFunction("PB_MoveCursorUp", function(move)
	if not ProgressPrinter.IsActive then
		return;
	fi;
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "A")); # move cursor up X lines
	ProgressPrinter.Cursor.y := ProgressPrinter.Cursor.y - move;
end);

InstallGlobalFunction("PB_MoveCursorToLine", function(n)
	local move;
	if not ProgressPrinter.IsActive then
		return;
	fi;
	move := n - ProgressPrinter.Cursor.y;
	if move > 0 then
		PB_MoveCursorDown(move);
	elif move < 0 then
		PB_MoveCursorUp(-move);
	fi;
end);

InstallGlobalFunction("PB_MoveCursorRight", function(move)
	if not ProgressPrinter.IsActive then
		return;
	fi;
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "C")); # move cursor right X characters
	ProgressPrinter.Cursor.x := ProgressPrinter.Cursor.x + move;
end);

InstallGlobalFunction("PB_MoveCursorLeft", function(move)
	if not ProgressPrinter.IsActive then
		return;
	fi;
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "D")); # move cursor left X characters
	ProgressPrinter.Cursor.x := ProgressPrinter.Cursor.x - move;
end);

InstallGlobalFunction("PB_MoveCursorToChar", function(n)
	local move;
	if not ProgressPrinter.IsActive then
		return;
	fi;
	move := n - ProgressPrinter.Cursor.x;
	if move > 0 then
		PB_MoveCursorRight(move);
	elif move < 0 then
		PB_MoveCursorLeft(-move);
	fi;
end);

InstallGlobalFunction("PB_MoveCursorToCoordinate", function(x, y)
	if not ProgressPrinter.IsActive then
		return;
	fi;
	PB_MoveCursorToChar(x);
	PB_MoveCursorToLine(y);
end);

InstallGlobalFunction("PB_MoveCursorToProcessEnd", function()
	if not ProgressPrinter.IsActive then
		return;
	fi;
	PB_MoveCursorToCoordinate(1, 1 + PB_Reduce(
		ProgressPrinter.RootProcess,
		{value, proc} -> value + proc.blocks.(ProgressPrinter.Pattern.id).h, 0
	));
end);

InstallGlobalFunction("PB_MoveCursorToStartOfLine", function()
	if not ProgressPrinter.IsActive then
		return;
	fi;
	WriteAll(STDOut, "\r"); # move cursor to the start of the line
	ProgressPrinter.Cursor.x := 1;
end);

InstallGlobalFunction("PB_ClearLine", function()
	if not ProgressPrinter.IsActive then
		return;
	fi;
	WriteAll(STDOut, "\033[2K"); # erase the entire line
end);

InstallGlobalFunction("PB_RefreshLine", function()
	if not ProgressPrinter.IsActive then
		return;
	fi;
	PB_MoveCursorToStartOfLine();
	PB_ClearLine();
end);

InstallGlobalFunction("PB_ClearScreen", function()
	if not ProgressPrinter.IsActive then
		return;
	fi;
	PB_MoveCursorToLine(ProgressPrinter.Dimensions.h);
	PB_RefreshLine();
	while ProgressPrinter.Cursor.y > 1 do
		PB_MoveCursorUp(1);
		PB_ClearLine();
	od;
end);

InstallGlobalFunction("PB_ClearProcess", function(process)
	local block, j;
	if not ProgressPrinter.IsActive then
		return;
	fi;
	if IsBound(process.blocks) then
		block := process.blocks.(ProgressPrinter.Pattern.id);
		PB_MoveCursorToLine(block.y);
		PB_RefreshLine();
		for j in [2 .. block.h] do
			PB_MoveCursorDown(1);
			PB_ClearLine();
		od;
	fi;
end);

InstallGlobalFunction("PB_ClearBlock", function(block)
	local empty, j;
	if not ProgressPrinter.IsActive then
		return;
	fi;
	empty := Concatenation(ListWithIdenticalEntries(block.w, " "));
	for j in [1 .. block.h] do
		PB_MoveCursorToCoordinate(block.x, block.y + j - 1);
		PB_Print(empty);
	od;
end);
