#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  ProgressBar.gi
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


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Global Variables
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


BindGlobal("PB_Global", rec(
	Process := fail,
	Terminal := fail,
	Printer := rec(),
	Alphabet := fail
));

PB_Global.Alphabet := "abcdefghijklmnopqrstuvwxyz";
Append(PB_Global.Alphabet, UppercaseString(PB_Global.Alphabet));

BindGlobal("PB_State", rec(
	Success := MakeImmutable("Success"),
	Failure := MakeImmutable("Failure"),
	Desyncronized := MakeImmutable("Desyncronized"),
));

BindGlobal("PB_CombineStates", function(stateBase, stateUpdate)
	if stateUpdate = PB_State.Success then
		return stateBase;
	else # some failure occured
		return stateUpdate;
	fi;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Helper Functions : Manipulating Cursor and Printing
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
		block := process.blocks.(PB_Global.Printer.Layout.id);
		PB_MoveCursorToLine(block.y);
		PB_RefreshLine();
		for j in [2 .. block.h] do
			PB_MoveCursorDown(1);
			PB_ClearLine();
		od;
	fi;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Helper Functions
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# returns number of digits
BindGlobal("PB_NrDigits", function(x)
	if x = 0 then
		return 1;
	else
		return LogInt(x, 10) + 1;
	fi;
end);

# returns string representation of length n
# by appending leading zeros to the digit x if necessary
BindGlobal("PB_StrNum", function(x, n)
	local nr_digits;
	nr_digits := PB_NrDigits(x);
	return Concatenation(Concatenation(ListWithIdenticalEntries(n - nr_digits, "0")), String(x));
end);

# returns time in milliseconds after 1.1.1970, 0:00 GMT
BindGlobal("PB_TimeStamp", function()
	local r;
	r := IO_gettimeofday(); # time in microseconds
	return r.tv_sec * 1000 + Int(r.tv_usec * 0.001);
end);

# returns record rec(d, h, min, s, ms) encoding a time given in milliseconds.
# args:
#	- t,		PosInt, time in milliseconds
BindGlobal("PB_TimeRecord", function(t)
	local quorem, d, h, min, sec, ms;
	# convert ms to time format
	# 1 d = 24 h
	# 1 h = 60 min
	# 1 min = 60 s
	# 1 s = 10^3 ms
	quorem := QuotientRemainder(t, 86400000);
	d := quorem[1];
	t := quorem[2];
	quorem := QuotientRemainder(t, 3600000);
	h := quorem[1];
	t := quorem[2];
	quorem := QuotientRemainder(t, 60000);
	min := quorem[1];
	t := quorem[2];
	quorem := QuotientRemainder(t, 1000);
	sec := quorem[1];
	ms := quorem[2];
	return rec(d := d, h := h, min := min, sec := sec, ms := ms);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Helper Functions : Manipulating Process Tree
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("PB_First", function(process, func)
	local child, res;
	if func(process) then
		return process;
	fi;
	for child in process.children do
		res := PB_First(child, func);
		if res <> fail then
			return res;
		fi;
	od;
	return fail;
end);

InstallGlobalFunction("PB_Reduce", function(process, func, init)
	local value, child;
	value := func(init, process);
	for child in process.children do
		value := PB_Reduce(child, func, value);
	od;
	return value;
end);

InstallGlobalFunction("PB_Perform", function(process, func)
	local child;
	func(process);
	for child in process.children do
		PB_Perform(child, func);
	od;
end);

BindGlobal("PB_AllProcesses", function()
	local L;
	L := [];
	PB_Perform(PB_Global.Process, function(proc) Add(L, proc); end);
	return L;
end);

# args: process[, mode]
# mode in ["all", "upper", "lower"]
BindGlobal("PB_Siblings", function(args...)
	local process, mode, parent, pos, n, L;
	process := args[1];
	mode := "all";
	if Length(args) > 1 then
		mode := args[2];
	fi;
	parent := process.parent;
	if parent = fail then
		return [];
	else
		pos := PositionProperty(parent.children, child -> child.id = process.id);
		n := Length(parent.children);
		if mode = "all" then
			L := [1 .. n];
			Remove(L, pos);
		elif mode = "upper" then
			L := [1 .. pos - 1];
		elif mode = "lower" then
			L := [pos + 1 .. n];
		else
			Error("unknown mode");
		fi;
		return parent.children{L};
	fi;
end);

InstallGlobalFunction("PB_ChildrenAndSelf", function(process)
	local L, child;
	L := [process];
	for child in process.children do
		Append(L, PB_ChildrenAndSelf(child));
	od;
	return L;
end);

BindGlobal("PB_Lower", function(process)
	local L, child, sibling;
	L := [];
	for child in process.children do
		Append(L, PB_ChildrenAndSelf(child));
	od;
	for sibling in PB_Siblings(process, "lower") do
		Append(L, PB_ChildrenAndSelf(sibling));
	od;
	return L;
end);

InstallGlobalFunction("PB_UpperUntilCaller", function(process, caller, L)
	local child;
	if process.id = caller.id then
		return true;
	fi;
	Add(L, process);
	for child in process.children do
		if PB_UpperUntilCaller(child, caller, L) then
			return true;
		fi;
	od;
	return false;
end);

BindGlobal("PB_Upper", function(process)
	local L;
	L := [];
	PB_UpperUntilCaller(PB_Global.Process, process, L);
	return L;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Display Options
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# Default options, immutable entries
BindGlobal("PB_DisplayOptionsDefault", Immutable(rec(
	# print bool options
	printID := false,
    printTotalTime := false,
	printTotalTimeOnlyForRoot := true,
	printETA := false,
	printETAOnlyForRoot := true,
	highlightCurStep := false,
	highlightColor := "red",
	highlightStyle := "default",
	# print symbols
	separator := " | ",
	branch := "|  ",
	bar_prefix := "[",
	bar_symbol_full := "=",
	bar_symbol_empty := "-",
	bar_suffix := "]",
)));

# Current options, mutable entries
BindGlobal("PB_DisplayOptions", ShallowCopy(PB_DisplayOptionsDefault));

InstallGlobalFunction( DisplayOptionsOfProgressBar,
function()
    Display(PB_DisplayOptions);
end);

BindGlobal("PB_SetOptions",
function(optionsBase, optionsUpdate)
    local r;
    for r in RecNames(optionsUpdate) do
        if not IsBound(optionsBase.(r)) then
            ErrorNoReturn("Invalid option for Progress Bar: ", r);
        fi;
		optionsBase.(r) := optionsUpdate.(r);
    od;
end);

# TODO: Setting Display Options should also change the pattern
InstallGlobalFunction(SetDisplayOptionsOfProgressBar,
function(options)
    PB_SetOptions(PB_DisplayOptions, options);
end);

InstallGlobalFunction(ResetDisplayOptionsOfProgressBar,
function()
    SetDisplayOptionsOfProgressBar(PB_DisplayOptionsDefault);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Printer Module : Progress Ratio
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


BindGlobal("PB_ProgressRatioPrinter", rec());

PB_ProgressRatioPrinter.dimensions := function(process, options)
	return rec(
		w := PB_NrDigits(process.nrSteps) * 2 + 1,
		h := 1
	);
end;

PB_ProgressRatioPrinter.generate := function(process, id, options)
	local block, curStep;
	block := process.blocks.(id);
	block.nr_digits := (block.w - 1) / 2;
	PB_MoveCursorToCoordinate(block.x, block.y);
	curStep := Maximum(0, process.curStep);
	PB_Print(Concatenation(String(curStep, block.nr_digits), "/", String(process.nrSteps, block.nr_digits)));
end;

PB_ProgressRatioPrinter.refresh := function(process, id, options)
	local block, nr_digits, curStep;
	block := process.blocks.(id);
	curStep := Maximum(0, process.curStep);
	nr_digits := PB_NrDigits(curStep);
	if nr_digits > block.nr_digits then
		return PB_State.Failure;
	fi;
	PB_MoveCursorToCoordinate(block.x, block.y);
	PB_Print(String(curStep, block.nr_digits));
	return PB_State.Success;
end;


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Printer Module : Text Printer
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


BindGlobal("PB_TextPrinter", rec());

PB_TextPrinter.dimensions := function(process, options)
	return rec(
		w := Length(options.text),
		h := 1
	);
end;

PB_TextPrinter.generate := function(process, id, options)
	local block;
	block := process.blocks.(id);
	PB_MoveCursorToCoordinate(block.x, block.y);
	PB_Print(options.text);
end;

PB_TextPrinter.refresh := function(process, id, options)
	return PB_State.Success;
end;

BindGlobal("PB_ProgressBarPrinter", rec(
	dimensions := function(process, options)
		return rec(
			w := fail,
			h := 1
		);
	end,
	generate := function(process, id, options)
		local block, curStep, r, bar_length, bar_length_full, bar_length_empty;
		block := process.blocks.(id);
		curStep := Maximum(0, process.curStep);
		# progress bar length
		r := curStep / process.nrSteps;
		bar_length := block.w - Length(options.bar_prefix) - Length(options.bar_suffix);
		bar_length_full := Int(bar_length * r);
		bar_length_empty := bar_length - bar_length_full;
		# print progress bar
		PB_MoveCursorToCoordinate(block.x, block.y);
		PB_Print(options.bar_prefix);
		if bar_length_full > 0 then
			PB_Print(Concatenation(ListWithIdenticalEntries(bar_length_full, options.bar_symbol_full)));
		fi;
		if bar_length_empty > 0 then
			PB_Print(Concatenation(ListWithIdenticalEntries(bar_length_empty, options.bar_symbol_empty)));
		fi;
		PB_Print(options.bar_suffix);
		# save data
		block.bar_length := bar_length;
		block.bar_length_full := bar_length_full;
	end,
	refresh := function(process, id, options)
		local block, curStep, r, bar_length_full, l;
		block := process.blocks.(id);
		curStep := Maximum(0, process.curStep);
		# progress bar length
		r := curStep / process.nrSteps;
		bar_length_full := Int(block.bar_length * r);
		# print progress bar
		l := bar_length_full - block.bar_length_full;
		if l > 0 then
			PB_MoveCursorToCoordinate(block.x + Length(options.bar_prefix) + block.bar_length_full, block.y);
			PB_Print(Concatenation(ListWithIdenticalEntries(l, options.bar_symbol_full)));
		fi;
		# save data
		block.bar_length_full := bar_length_full;
		return PB_State.Success;
	end,
));

BindGlobal("PB_IndentPrinter", rec());

PB_IndentPrinter.dimensions := function(process, options)
	return rec(
		w := Length(options.branch) * process.depth,
		h := fail
	);
end;

PB_IndentPrinter.print := function(process, id, options)
	local block, indent, i, j;
	block := process.blocks.(id);
	indent := Concatenation(ListWithIdenticalEntries(Length(options.branch), " "));
	indent := ListWithIdenticalEntries(process.depth, indent);
	for i in block.branches do
		indent[i + 1] := options.branch;
	od;
	indent := Concatenation(indent);
	for j in [block.y .. block.y + block.h - 1] do
		PB_MoveCursorToCoordinate(block.x, j);
		PB_Print(indent);
	od;
end;

PB_IndentPrinter.generate := function(process, id, options)
	local block, parent, child, grandchild, branch;
	block := process.blocks.(id);
	block.branches := [];
	parent := process.parent;
	if parent = fail then
		return;
	fi;
	for branch in parent.blocks.(id).branches do
		AddSet(block.branches, branch);
	od;
	# Situation: We need to update the children of all (upper) siblings
	# | parent
	#    | parent.child
	#       | parent.child.child
	#    | process
	for child in PB_Siblings(process, "upper") do
		for grandchild in child.children do
			PB_Perform(grandchild, function(proc)
				AddSet(proc.blocks.(id).branches, process.depth);
				PB_IndentPrinter.print(proc, id, options);
			end);
		od;
	od;
	# Situation: We need to update ourselves
	# | parent.parent
	#    | parent
	#       | process
	#    | parent.parent.child
	if parent.parent <> fail then
		if PositionProperty(parent.parent.children, child -> child.id = parent.id) < Length(parent.parent.children) then
			AddSet(block.branches, parent.depth);
		fi;
	fi;
	PB_IndentPrinter.print(process, id, options);
end;

PB_IndentPrinter.refresh := function(process, id, options)
	return true;
end;

# TODO: Remove
BindGlobal("PB_SetFont", function(options)
	PB_SetStyle(options.highlightStyle);
    PB_SetForegroundColor(options.highlightColor);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Process Printer : Layout
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


PB_Global.Printer.LayoutOptionsDefault := Immutable(rec(
	align := "horizontal",
	sync := [],
));

PB_Global.Printer.Layout := rec(
	id := "process",
	layout_options := rec(),
	isActive := ReturnTrue,
	children := [
	rec(
		id := "left",
		layout_options := rec(),
		isActive := ReturnTrue,
		printer := PB_IndentPrinter,
		printer_options := rec(
			branch := PB_DisplayOptions.branch
		)
	),
	rec(
		id := "right",
		layout_options := rec(),
		isActive := ReturnTrue,
		children := [
		rec(
			id := "bottom line",
			layout_options := rec(),
			isActive := ReturnTrue,
			children := [
			rec(
				id := "progress bar",
				layout_options := rec(),
				isActive := ReturnTrue,
				printer := PB_ProgressBarPrinter,
				printer_options := rec(
					bar_prefix := PB_DisplayOptions.bar_prefix,
					bar_suffix := PB_DisplayOptions.bar_suffix,
					bar_symbol_empty := PB_DisplayOptions.bar_symbol_empty,
					bar_symbol_full := PB_DisplayOptions.bar_symbol_full,
				),
			),
			rec(
				id := "separator 1",
				layout_options := rec(),
				isActive := ReturnTrue,
				printer := PB_TextPrinter,
				printer_options := rec(
					text := PB_DisplayOptions.separator
				),
			),
			rec(
				id := "progress ratio",
				layout_options := rec(
					# sync width among all blocks with this id
					sync := ["w"]
				),
				isActive := ReturnTrue,
				printer := PB_ProgressRatioPrinter,
				printer_options := rec(),
			)
			]
		)
		]
	)
	]
);

PB_Global.Printer.InitialConfigurationRecord := [];


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Process Printer : Allocation of Blocks
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# get bounding box of block
BindGlobal("PB_GetBounds", function(process, pattern)
	local bounds;
	if IsBound(process.blocks.(pattern.id)) then
		bounds := process.blocks.(pattern.id);
	else
		process.blocks.(pattern.id) := rec(x := fail, y := fail, w := fail, h := fail);
		bounds := process.blocks.(pattern.id);
	fi;
	return bounds;
end);

# get bounding box of block
InstallGlobalFunction("PB_SetBounds", function(process, pattern, values)
	local bounds, param, i, children, child;
	bounds := PB_GetBounds(process, pattern);
	for param in ["x", "y", "w", "h"] do
		i := Position(PB_Global.Printer.Variables, rec(id := pattern.id, param := param));
		bounds.(param) := values[i];
	od;
	if IsBound(pattern.children) then
		children := Filtered(pattern.children, child -> child.isActive(process));
		for child in children do
			PB_SetBounds(process, child, values);
		od;
	fi;
end);

InstallGlobalFunction("PB_InitializeParent", function(pattern, parent)
	local child;
	pattern.parent := parent;
	if IsBound(pattern.children) then
		for child in pattern.children do
			PB_InitializeParent(child, pattern);
		od;
	fi;
end);

# node sets dimensions of itself
InstallGlobalFunction("PB_InitializeDimension", function(process, pattern)
	local bounds, children, child, dim, dir, value, layout_options, state;
	state := PB_State.Success;
	# inner node
	if IsBound(pattern.children) then
		children := Filtered(pattern.children, child -> child.isActive(process));
		for child in children do
			state := PB_CombineStates(state, PB_InitializeDimension(process, child));
		od;
	# leaf node
	else
		layout_options := ShallowCopy(PB_Global.Printer.LayoutOptionsDefault);
		PB_SetOptions(layout_options, pattern.layout_options);
		dim := pattern.printer.dimensions(process, pattern.printer_options);
		bounds := PB_GetBounds(process, pattern);
		for dir in ["w", "h"] do
			if dir in layout_options.sync and process <> PB_Global.Process then
				value := PB_Global.Process.blocks.(pattern.id).(dir);
				if value < dim.(dir) then
					value := dim.(dir);
					PB_Perform(PB_Global.Process, function(proc)
						local pos;
						if proc <> process then
							pos := Position(proc.configurationRecord, [1, rec(id := pattern.id, param := dir), PB_GetBounds(proc, pattern).(dir)]);
							proc.configurationRecord[pos] := [1, rec(id := pattern.id, param := dir), value];
							proc.configurationSystem.b[pos] := value;
						fi;
					end);
					state := PB_CombineStates(state, PB_State.Desyncronized);
				fi;
			else
				value := dim.(dir);
			fi;
			bounds.(dir) := value;
			if bounds.(dir) <> fail then
				Add(process.configurationRecord, [1, rec(id := pattern.id, param := dir), bounds.(dir)]);
			fi;
		od;
	fi;
	return state;
end);

InstallGlobalFunction("PB_InitializeVariables", function(pattern)
	local param, child;
	for param in ["x", "y", "w", "h"] do
		Add(PB_Global.Printer.Variables, rec(id := pattern.id, param := param));
	od;
	if IsBound(pattern.children) then
		for child in pattern.children do
			PB_InitializeVariables(child);
		od;
	fi;
end);

BindGlobal("PB_ConfigurationSystem", function(configuration)
	local M, b, n, c, column, m, i, j;
	M := [];
	b := [];
	n := Length(PB_Global.Printer.Variables);
	for c in configuration do
		column := ListWithIdenticalEntries(n, 0);
		m := Length(c);
		for i in [1 .. (m - 1) / 2] do
			j := Position(PB_Global.Printer.Variables, c[2 * i]);
			column[j] := c[2 * i - 1];
		od;
		Add(M, column);
		Add(b, c[m]);
	od;
	TransposedMatDestructive(M);
	return rec(M := M, b := b);
end);

InstallGlobalFunction("PB_AlignBlock", function(process, pattern)
	local layout_options, c, children, child, i, coord, dir;
	if not pattern.isActive(process) then
		return;
	fi;
	layout_options := ShallowCopy(PB_Global.Printer.LayoutOptionsDefault);
	PB_SetOptions(layout_options, pattern.layout_options);
	# inner node
	if IsBound(pattern.children) then
		children := Filtered(pattern.children, child -> child.isActive(process));
		# child dimensions sum up to node dimension for dir
		if layout_options.align = "horizontal" then
			dir := "w";
		else # vertical
			dir := "h";
		fi;
		c := [];
		for child in children do
			Append(c, [1, rec(id := child.id, param := dir)]);
		od;
		Append(c, [-1, rec(id := pattern.id, param := dir)]);
		Add(c, 0);
		Add(process.configurationRecord, c);
		# child dimensions are equal to node dimension for dir
		if layout_options.align = "horizontal" then
			dir := "h";
		else # vertical
			dir := "w";
		fi;
		for child in children do
			c := [];
			Append(c, [1, rec(id := child.id, param := dir)]);
			Append(c, [-1, rec(id := pattern.id, param := dir)]);
			Add(c, 0);
			Add(process.configurationRecord, c);
		od;
		# child coordinate are shifted for coord
		if layout_options.align = "horizontal" then
			coord := "x";
			dir := "w";
		else # vertical
			coord := "y";
			dir := "h";
		fi;
		c := [];
		Append(c, [1, rec(id := children[1].id, param := coord)]);
		Append(c, [-1, rec(id := pattern.id, param := coord)]);
		Add(c, 0);
		Add(process.configurationRecord, c);
		for i in [1 .. Length(children) - 1] do
			c := [];
			Append(c, [1, rec(id := children[i].id, param := coord)]);
			Append(c, [1, rec(id := children[i].id, param := dir)]);
			Append(c, [-1, rec(id := children[i + 1].id, param := coord)]);
			Add(c, 0);
			Add(process.configurationRecord, c);
		od;
		# child coordinate are equal to node coordinate for coord
		if layout_options.align = "horizontal" then
			coord := "y";
		else # vertical
			coord := "x";
		fi;
		for child in children do
			c := [];
			Append(c, [1, rec(id := child.id, param := coord)]);
			Append(c, [-1, rec(id := pattern.id, param := coord)]);
			Add(c, 0);
			Add(process.configurationRecord, c);
		od;
		# recursion
		for child in children do
			PB_AlignBlock(process, child);
		od;
	fi;
end);

BindGlobal("PB_AllocateBlocks", function(process)
	local pattern, bounds, param, data, configuration, state, procs, proc, M, b, values;
	# initalize process pattern
	process.blocks := rec();
	pattern := PB_Global.Printer.Layout;
	bounds := PB_GetBounds(process, pattern);
	bounds.x := 1;
	bounds.y := Sum(PB_Upper(process), upper -> upper.blocks.(pattern.id).h) + 1;
	bounds.w := PB_Global.Terminal.screenWidth;
	# initialize parents
	if not IsBound(pattern.parent) then
		PB_InitializeParent(pattern, fail);
	fi;
	# initialize variables for bounds
	if not IsBound(PB_Global.Printer.Variables) then
		PB_Global.Printer.Variables := [];
		PB_InitializeVariables(pattern);
	fi;
	# initialize configuration record with root pattern bounds
	process.configurationRecord := [];
	for param in ["x", "y", "w"] do
		Add(process.configurationRecord, [1, rec(id := pattern.id, param := param), bounds.(param)]);
	od;
	# add configurations via align
	Append(process.configurationRecord, PB_Global.Printer.InitialConfigurationRecord);
	PB_AlignBlock(process, pattern);
	# add configurations via dimensions of the printer blocks,
	# where some might still be set to fail, if they are dynamic.
	state := PB_InitializeDimension(process, pattern);
	# compute configuration system for process
	process.configurationSystem := PB_ConfigurationSystem(process.configurationRecord);
	# solve linear system and set all bounds
	if state = PB_State.Success then
		procs := [process];
	elif state = PB_State.Desyncronized then
		procs := PB_AllProcesses();
	else # TODO
		Error();
	fi;
	for proc in procs do
		M := proc.configurationSystem.M;
		b := proc.configurationSystem.b;
		values := SolutionIntMat(M, b);
		PB_SetBounds(proc, pattern, values);
	od;
	return state;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Progress Printing
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("PB_PrintBlock", function(process, pattern, doGenerate)
	local child;
	# TODO: activity has changed
	if pattern.isActive(process) then
		if not IsBound(process.blocks.(pattern.id)) then
			Error();
		fi;
	else
		if IsBound(process.blocks.(pattern.id)) then
			Error();
		fi;
	fi;

	# composition block (inner node)
	if IsBound(pattern.children) then
		for child in pattern.children do
			if PB_PrintBlock(process, child, doGenerate) = PB_State.Failure then
				return PB_State.Failure;
			fi;
		od;
		return PB_State.Success;
	fi;

	# printer block (leaf node)
	if doGenerate then
		pattern.printer.generate(process, pattern.id, pattern.printer_options);
		return PB_State.Success;
	else
		return pattern.printer.refresh(process, pattern.id, pattern.printer_options);
	fi;
end);

BindGlobal("PB_PrintProcess", function(process, doGenerate)
	local state;

	state := PB_State.Success;

	if process.blocks = rec() then
		state := PB_CombineStates(state, PB_AllocateBlocks(process));
		doGenerate := true;
	fi;

	if process.curStep < 0 then
		doGenerate := true;
	fi;

	if doGenerate then
		PB_ClearProcess(process);
	fi;

	if PB_PrintBlock(process, PB_Global.Printer.Layout, doGenerate) = PB_State.Failure then
		# refresh had a failure, i.e. information doesn't fit the block anymore.
		state := PB_CombineStates(state, PB_AllocateBlocks(process));
		PB_PrintBlock(process, PB_Global.Printer.Layout, true);
	fi;

	return state;
end);

BindGlobal("PB_PrintProgress", function(process)
	local proc, child, root, state, procs;

	state := PB_State.Success;

	# Did root process start?
	root := PB_Global.Process;
	if process = root and process.curStep = 0 then
		PB_ResetTerminal();
		PB_HideCursor();
	fi;

	# Is current process different to last time?
	if IsBound(PB_Global.Printer.CurProcess) and PB_Global.Printer.CurProcess.id <> process.id then
		proc := PB_Global.Printer.CurProcess;
		PB_Global.Printer.CurProcess := process;
		PB_PrintProcess(proc, true);
	else
		PB_Global.Printer.CurProcess := process;
	fi;

	# Print current process
	state := PB_CombineStates(state, PB_PrintProcess(process, false));

	# Print all descendants
	for child in process.children do
		PB_Perform(child, function(proc)
			state := PB_CombineStates(state, PB_PrintProcess(proc, true));
		end);
	od;

	if state = PB_State.Desyncronized then
		PB_Perform(root, function(proc)
			PB_PrintProcess(proc, true);
		end);
	fi;

	# Did root process terminate?
	if process = root and process.curStep = process.nrSteps then
		PB_MoveCursorToLine(PB_Global.Terminal.usedLines);
		PB_PrintNewLine();
		PB_ResetStyleAndColor();
		PB_ShowCursor();
	fi;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Process
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("ProcessIterator", function(args...)
	local iter, nrSteps, processArgs, process, processIter;
	if IsListOrCollection(args[1]) then
		iter := Iterator(args[1]);
		nrSteps := Size(args[1]);
	elif IsIterator(args[1]) then
		iter := args[1];
		nrSteps := infinity;
	elif IsRecord(args[1]) then
		if not (IsBound(args[1].iter) and IsBound(args[1].nrSteps)) then
			Error("iterator-like object is given as record and
				   therefore must contain the entries iter and nrSteps");
		fi;
		iter := args[1].iter;
		nrSteps := args[1].nrSteps;
		if not IsIterator(iter) then
			Error("iter entry is not an iterator");
		fi;
	else
		Error("Unknown type of iterator-like object");
	fi;
	processArgs := [nrSteps];
	Append(processArgs, args{[2 .. Length(args)]});
	process := CallFuncList(SetProcess, processArgs);
	processIter := rec(process := process, iter := iter);
	processIter.NextIterator := function(procIter)
		UpdateProcess(procIter!.process);
		return NextIterator(procIter!.iter);
	end;
	processIter.IsDoneIterator := function(procIter)
		local isDone;
		isDone := IsDoneIterator(procIter!.iter);
		if isDone then
			UpdateProcess(procIter!.process);
		fi;
		return isDone;
	end;
	processIter.ShallowCopy := function(procIter)
		return ProcessIterator(
			rec(
				iter := ShallowCopy(procIter!.iter),
				nrSteps := procIter!.process.nrSteps
			),
			procIter!.process.id,
			procIter!.process.parent,
			procIter!.process.content
		);
	end;
	processIter.PrintObj := function(procIter)
		PrintObj(procIter!.iter);
	end;
	processIter.ViewObj := function(procIter)
		ViewObj(procIter!.iter);
	end;
	return IteratorByFunctions(processIter);
end);

BindGlobal("PB_GetProcess", function(procObj)
	local process;
	if IsString(procObj) then
		process := PB_First(PB_Global.Process, proc -> proc.id = procObj);
		if process = fail then
			Error("Cannot find process");
		fi;
	elif IsIterator(procObj) then
		process := procObj!.process;
	else
		process := procObj;
	fi;
	return process;
end);

InstallGlobalFunction("SetProcess", function(args...)
	local nrSteps, id, parent, content, process, child, pos;

	# process arguments
	nrSteps := args[1];
	if not (IsPosInt(nrSteps) or IsInfinity(nrSteps)) then
		Error("nrSteps is not a positive integer or infinity");
	fi;
	if Length(args) >= 2 then
		id := args[2];
		if not IsString(id) then
			Error("id must be a string");
		fi;
	else
		id := List([1 .. 100], i -> PseudoRandom(PB_Global.Alphabet));
	fi;
	if Length(args) >= 3 then
		parent := PB_GetProcess(args[3]);
	else
		parent := fail;
	fi;
	if Length(args) >= 4 then
		content := args[4];
	else
		content := rec();
	fi;

	# create process
	process := rec(
		id := id,
		parent := parent,
		children := [],
		depth := 0,
		totalTime := 0,
		timeStamp := fail,
		curStep := -1,
		nrSteps := nrSteps,
		content := content,
		blocks := rec(),
	);

	# add process to tree
	if parent = fail then
		PB_Global.Process := process;
	else
		pos := PositionProperty(parent.children, proc -> proc.id = id);
		if pos = fail then
			process.depth := parent.depth + 1;
			Add(parent.children, process);
		else
			process := parent.children[pos];
			ResetProcess(process);
			process.nrSteps := nrSteps;
			process.content := content;
		fi;
	fi;

	return process;
end);


InstallGlobalFunction("UpdateProcess", function(args...)
	local process, content, r, child;

	# arguments
	process := PB_GetProcess(args[1]);
	if Length(args) >= 2 then
		content := args[2];
	else
		content := rec();
	fi;

	# update content
	for r in RecNames(content) do
		process.content.(r) := content.(r);
	od;

	# increment step
	process.curStep := process.curStep + 1;
	# TODO: deal with this case in a nicer way
	if process.curStep > process.nrSteps then
		process.nrSteps := infinity;
	fi;

	# reset children if necessary
	if process.curStep < process.nrSteps then
		for child in process.children do
			ResetProcess(child);
		od;
	fi;

	RefreshProcess(process);
end);

InstallGlobalFunction("RefreshProcess", function(procObj)
	local process, t, dt, child;

	# arguments
	process := PB_GetProcess(procObj);

	# set timers
	t := PB_TimeStamp();
	if process.timeStamp <> fail then
		dt := t - process.timeStamp;
		process.totalTime := process.totalTime + dt;
	fi;
	process.timeStamp := t;

	# print
	PB_PrintProgress(process);
end);

InstallGlobalFunction("ResetProcess", function(procObj)
	local process;
	process := PB_GetProcess(procObj);
	PB_Perform(process, function(proc)
		process.totalTime := 0;
		process.timeStamp := fail;
		process.curStep := -1;
	end);
end);
