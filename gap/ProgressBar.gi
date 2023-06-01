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


PB_Process := fail;
PB_Terminal := fail;
PB_State := fail;


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Helper Functions : Manipulating Cursor and Printing
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# ANSI Escape Sequences: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797

BindGlobal("PB_Print", function(msg)
	WriteAll(STDOut, msg);
	PB_Terminal.cursorHorizontalPos := PB_Terminal.cursorHorizontalPos + Length(msg);
end);

BindGlobal("PB_PrintNewLine", function(args...)
	local n;
	n := 1;
	if Length(args) = 1 then
		n := args[1];
	fi;
	WriteAll(STDOut, Concatenation(ListWithIdenticalEntries(n, "\n"))); # create n new lines
	PB_Terminal.cursorVerticalPos := PB_Terminal.cursorVerticalPos + n;
end);

BindGlobal("PB_ResetModeAndColor", function()
	WriteAll(STDOut, "\033[0m");
end);

BindGlobal("PB_SetMode", function(mode)
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

BindGlobal("PB_MoveCursorToStartOfLine", function()
	WriteAll(STDOut, "\r"); # move cursor to the start of the line
	PB_Terminal.cursorHorizontalPos := 1;
end);

BindGlobal("PB_MoveCursorDown", function(move)
	local n;
	move := AbsInt(move);
	n := PB_Terminal.cursorVerticalPos + move;
	if PB_Terminal.usedLines < n then
		move := PB_Terminal.usedLines - PB_Terminal.cursorVerticalPos;
		WriteAll(STDOut, Concatenation("\033[", String(move), "B")); # move cursor down X lines
		PB_PrintNewLine(n - PB_Terminal.usedLines);
		PB_Terminal.usedLines := n;
	else
		WriteAll(STDOut, Concatenation("\033[", String(move), "B")); # move cursor down X lines
		PB_Terminal.cursorVerticalPos := PB_Terminal.cursorVerticalPos + move;
	fi;
	PB_MoveCursorToStartOfLine();
end);

BindGlobal("PB_MoveCursorUp", function(move)
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "A")); # move cursor up X lines
	PB_Terminal.cursorVerticalPos := PB_Terminal.cursorVerticalPos - move;
	PB_MoveCursorToStartOfLine();
end);

BindGlobal("PB_MoveCursorToLine", function(n)
	local move;
	move := n - PB_Terminal.cursorVerticalPos;
	if move > 0 then
		PB_MoveCursorDown(move);
	elif move < 0 then
		PB_MoveCursorUp(-move);
	fi;
end);

BindGlobal("PB_MoveCursorRight", function(move)
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "C")); # move cursor right X characters
	PB_Terminal.cursorHorizontalPos := PB_Terminal.cursorHorizontalPos + move;
end);

BindGlobal("PB_MoveCursorLeft", function(move)
	move := AbsInt(move);
	WriteAll(STDOut, Concatenation("\033[", String(move), "D")); # move cursor left X characters
	PB_Terminal.cursorHorizontalPos := PB_Terminal.cursorHorizontalPos - move;
end);

BindGlobal("PB_MoveCursorToChar", function(n)
	local move;
	move := n - PB_Terminal.cursorHorizontalPos;
	if move > 0 then
		PB_MoveCursorRight(move);
	elif move < 0 then
		PB_MoveCursorLeft(-move);
	fi;
end);

BindGlobal("PB_RefreshLine", function()
	WriteAll(STDOut, "\033[2K"); # erase the entire line
	PB_MoveCursorToStartOfLine();
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Helper Functions : Manipulating Strings
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
BindGlobal("PB_GetTime", function()
	local r;
	r := IO_gettimeofday();
	return r.tv_sec * 1000 + Int(r.tv_usec * 0.001);
end);

# returns string representation of a time given in milliseconds.
# The string is of the form `h:min:s` e.g. `1:23:42`
# args:
#	- t,		PosInt, time in milliseconds
#	- printMS,	Bool, whether to print milliseconds
#				[default: false]
BindGlobal("PB_StrTime", function(args...)
	local t, printMS, quorem, h, min, sec, ms;
	t := args[1];
	printMS := false;
	if Length(args) > 1 then
		printMS := args[2];
	fi;
	# convert ms to time format
	quorem := QuotientRemainder(t, 3600000);
	h := quorem[1];
	t := quorem[2];
	quorem := QuotientRemainder(t, 60000);
	min := quorem[1];
	t := quorem[2];
	quorem := QuotientRemainder(t, 1000);
	sec := quorem[1];
	ms := quorem[2];
	# convert time numbers to string
	h := String(h, 1);
	min := PB_StrNum(min, 2);
	sec := PB_StrNum(sec, 2);
	ms := PB_StrNum(ms, 3);
	# compose string
	if printMS then
		return JoinStringsWithSeparator([h, min, sec, ms], ":");
	else
		return JoinStringsWithSeparator([h, min, sec], ":");
	fi;
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

BindGlobal("PB_ProcessTime", function(process)
	return PB_Reduce(process, {t, proc} -> t + proc.totalTime, 0);
end);

BindGlobal("PB_ProcessMaxSteps", function(process)
	return PB_Reduce(process, {m, proc} -> Maximum(m, proc.nrSteps), 0);
end);

BindGlobal("PB_FindProcess", function(process, id)
	return PB_First(process, proc -> proc.id = id);
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
		Append(L, PB_ChildrenAndSelf(child, false));
	od;
	for sibling in PB_Siblings(process, "lower") do
		Append(L, PB_ChildrenAndSelf(sibling, false));
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
	PB_UpperUntilCaller(PB_Process, process, L);
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
    printTotalTime := false,
	printETA := true,
	highlightCurStep := false,
	highlightColor := "red",
	highlightMode := "default",
	# print symbols
	separator := " | ",
	branch := " | ",
	bar_prefix := " [",
	bar_symbol_full := "=",
	bar_symbol_empty := "-",
	bar_suffix := "] ",
)));

# Current options, mutable entries
BindGlobal("PB_DisplayOptions", ShallowCopy(PB_DisplayOptionsDefault));

InstallGlobalFunction( DisplayOptionsForProgressBar,
function()
    Display(PB_DisplayOptions);
end);

BindGlobal("PB_SetDisplayOptions",
function(optionsBase, optionsUpdate)
    local r;
    for r in RecNames(optionsUpdate) do
        if not IsBound(optionsBase.(r)) then
            ErrorNoReturn("Invalid option for Progress Bar: ", r);
        fi;
		optionsBase.(r) := optionsUpdate.(r);
    od;
end);

InstallGlobalFunction(SetDisplayOptionsForProgressBar,
function(options)
    PB_SetDisplayOptions(PB_DisplayOptions, options);
end);

InstallGlobalFunction(ResetDisplayOptionsForProgressBar,
function()
    SetDisplayOptionsForProgressBar(PB_DisplayOptionsDefault);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Progress Bar : Printer
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# The Process Printer has an internal list of Printers for smaller parts, and deals with the "communication" of those Printers.
# It stores global information in PB_State that is shared between all Printers.
# A Printer is a record with a reserveSpace, a print and a refresh function.
# The reserveSpace function returns an integer
# that states how many characters need to be reserved for this part of the printing process.
# It may be zero, if no space is needed. (For example if space needs to be allocated during runtime.)
# It returns fail, if further information is required to compute the amount of space needed.
# The print and refresh function get as input a process and the amount of reserved space.

BindGlobal("PB_PrintProcess", function(process)
	return;
end);

BindGlobal("PB_SeparatorPrinter", rec(
	ReserveSpace := function(process)
		return Length(PB_DisplayOptions.separator);
	end,
	Print := function(process, space)
		PB_Print(PB_DisplayOptions.separator);
	end,
	Refresh := function(process, space)
		return;
	end,
));

BindGlobal("PB_SetFont", function(options)
	PB_SetMode(options.highlightMode);
    PB_SetForegroundColor(options.highlightColor);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Progress Bar
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("PB_PrintProgress", function(process)
	local options, root, curProcess, curStep, nrSteps, totalTime, title, depth, branches, nrLines, startLine, t, indent, i,
	r, a, progress_percent, progress_ratio, progress_expected_time, progress_info,
	bar_length, bar_length_full, bar_length_empty, child, l;

	# initialization
	options := ShallowCopy(PB_DisplayOptions);
	PB_SetDisplayOptions(options, process.options);
	root := PB_Process;
	PB_Terminal.widthScreen := SizeScreen()[1] - 1;
	PB_Terminal.nr_digits := PB_NrDigits(PB_ProcessMaxSteps(root));
	curProcess := fail;
	if IsBound(PB_Terminal.curProcess) then
		curProcess := PB_Terminal.curProcess;
	fi;
	curStep := process.curStep;
	nrSteps := process.nrSteps;
	totalTime := process.totalTime;
	title := process.title;
	depth := process.depth;
	branches := process.branches;
	nrLines := 0;
	startLine := Sum(PB_Upper(process), proc -> proc.nrLines) + 1;

	# init indent
	if depth = 0 then
		indent := "";
	else
		indent := Concatenation(ListWithIdenticalEntries(Length(options.branch), " "));
		indent := ListWithIdenticalEntries(depth, indent);
		for i in branches do
			indent[i + 1] := options.branch;
		od;
		indent := Concatenation(indent);
	fi;

	# print headers and set font
	# TODO: detect if option was changed during execution
	if options.printTotalTime then
		t := PB_StrTime(PB_ProcessTime(process));
		if t <> PB_Terminal.totalTime then
			PB_Terminal.totalTime := t;
			PB_MoveCursorToLine(1);
			PB_RefreshLine();
			PB_Print(options.branch);
			PB_Print("Total Time ");
			PB_Print(t);
		fi;
		startLine := startLine + 1;
	fi;

	# move cursor to startline of process
	PB_MoveCursorToLine(startLine);

	# TODO: fix this, we need to detect change in curProcess
	if options.highlightCurStep and process = curProcess and not (process = root and curStep >= nrSteps) then
		PB_SetFont(options);
	else
		PB_ResetModeAndColor();
	fi;

	# TODO: detect if option was changed during execution
	if title <> fail then
		PB_RefreshLine();
		PB_Print(indent);
		PB_Print(options.branch);
		PB_Print(title);
		PB_PrintNewLine();
		nrLines := nrLines + 1;
	fi;

	# progress info
	if curStep = 0 then
		PB_RefreshLine();
		progress_info := [];
		r := curStep / nrSteps;
		progress_percent := Concatenation(String(Int(r * 100), 3), "%");
		Add(progress_info, progress_percent);
		progress_ratio := Concatenation(String(curStep, PB_Terminal.nr_digits), "/", String(nrSteps));
		Add(progress_info, progress_ratio);
		if options.printETA then
			# if curStep > 0 then
			# 	a := totalTime / curStep;
			# 	progress_expected_time := Concatenation("eta ", PB_StrTime(Int(a * (nrSteps - curStep))));
			# else
			# 	progress_expected_time := "eta ?:??:??";
			# fi;
			progress_expected_time := "eta ?:??:??";
			Add(progress_info, progress_expected_time);
		fi;
		progress_info := JoinStringsWithSeparator(progress_info, options.separator);

		# progress bar length
		bar_length := PB_Terminal.widthScreen - Length(indent) - Length(options.bar_prefix) - Length(options.bar_suffix) - Length(progress_info);
		bar_length_full := Int(bar_length * r);
		bar_length_empty := bar_length - bar_length_full;

		# print progress bar
		PB_RefreshLine();
		PB_Print(indent);
		PB_Print(options.bar_prefix);
		if bar_length_full > 0 then
			PB_Print(Concatenation(ListWithIdenticalEntries(bar_length_full, options.bar_symbol_full)));
		fi;
		if bar_length_empty > 0 then
			PB_Print(Concatenation(ListWithIdenticalEntries(bar_length_empty, options.bar_symbol_empty)));
		fi;
		PB_Print(options.bar_suffix);
		PB_Print(progress_info);
		PB_ResetModeAndColor();

		# save some stuff
		process.bar_length := bar_length;
		process.bar_length_full := bar_length_full;
	else
		# TODO: fix this dirty hack
		PB_MoveCursorToStartOfLine();
		# progress bar length
		r := curStep / nrSteps;
		bar_length := process.bar_length;
		bar_length_full := Int(bar_length * r);
		bar_length_empty := bar_length - bar_length_full;

		# print progress bar
		PB_MoveCursorToChar(Length(indent) + Length(options.bar_prefix) + process.bar_length_full + 1);
		l := bar_length_full - process.bar_length_full;
		if l > 0 then
			PB_Print(Concatenation(ListWithIdenticalEntries(l, options.bar_symbol_full)));
		fi;
		PB_MoveCursorRight(bar_length_empty + Length(options.bar_suffix));
		PB_Print(String(Int(r * 100), 3));
		PB_MoveCursorRight(1 + Length(options.separator));
		PB_Print(String(curStep, PB_Terminal.nr_digits));
		PB_MoveCursorRight(1 + PB_Terminal.nr_digits);
		if options.printETA then
			PB_MoveCursorRight(Length(options.separator) + 4);
			a := totalTime / curStep;
			PB_Print(PB_StrTime(Int(a * (nrSteps - curStep))));
		fi;

		# save some stuff
		process.bar_length_full := bar_length_full;
	fi;
	nrLines := nrLines + 1;

	# update cursor
	process.nrLines := nrLines;
	PB_Terminal.cursorVerticalPos := PB_Terminal.cursorVerticalPos + nrLines - 1;
	PB_Terminal.usedLines := Maximum(PB_Terminal.usedLines, startLine + nrLines - 1);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Process
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("DeclareProcess", function(args...)
	local root, nrSteps, parent, id, title, displayOptions, options, process, child, grandchild, pos, branch;

	# process arguments
	root := PB_Process;
	nrSteps := args[1];
	parent := fail;
	id := "pyqUyiFnuGQrWlkQrcbZoAFNDrZDZVPorcZihZAzRiufEfSTCBzzkGhzujIc";
	if Length(args) > 1 then
		if IsString(args[2]) then
			parent := PB_FindProcess(root, args[2]);
			if parent = fail then
				Error("Parent has not yet been declared");
			fi;
		else
			parent := args[2];
		fi;
		id := args[3];
	fi;
	title := fail;
	if Length(args) > 3 then
		title := args[4];
	fi;
	options := rec();
	if Length(args) > 4 then
		options := args[5];
	fi;

	# create process
	process := rec(
		parent := parent,
		children := [],
		# total time of process at the start of current step
		totalTime := 0,
		# last time stamp of process at the start of current step
		timeStamp := fail,
		# current step of process
		curStep := 0,
		# total number of steps for process to be marked as finished
		nrSteps := nrSteps,
		# id of process
		id := id,
		# title of step for process
		title := title,
		# depth of process
		depth := 0,
		# additional branches on the left of process
		branches := [],
		# number of lines reserved by this process
		nrLines := 0,
		# options of process overriding the global options
		options := options,
	);

	if parent = fail then
		PB_HideCursor();
		PB_Process := process;
		PB_Terminal := rec(
			cursorVerticalPos := 1,
			cursorHorizontalPos := 1,
			usedLines := 1,
			totalTime := fail,
		);
	else
		pos := PositionProperty(parent.children, proc -> proc.id = id);
		if pos = fail then
			process.depth := parent.depth + 1;
			# Situation: We need to update the children of all (upper) siblings
			# | parent
			#    | parent.child
			#       | parent.child.child
			#    | process
			for child in parent.children do
				for grandchild in child.children do
					PB_Perform(grandchild, function(proc)
						AddSet(proc.branches, process.depth);
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
					AddSet(process.branches, parent.depth);
					for branch in parent.branches do
						AddSet(process.branches, branch);
					od;
				fi;
			fi;
			Add(parent.children, process);
		else
			process := parent.children[pos];
			PB_ResetProcess(process);
		fi;
	fi;

	return process;
end);

InstallGlobalFunction("StartProcess", function(args...)
	local root, proc, displayOptions, options, process;

	root := PB_Process;
	if Length(args) = 1 and not IsInt(args[1]) then
		if IsString(args[1]) then
			process := PB_FindProcess(root, args[1]);
		else
			process := args[1];
		fi;
		PB_ResetProcess(process);
	else
		process := CallFuncList(DeclareProcess, args);
	fi;

	# print process
	if IsBound(PB_Terminal.curProcess) and PB_Terminal.curProcess.id <> process.id then
		proc := PB_Terminal.curProcess;
		PB_Terminal.curProcess := process;
		PB_PrintProgress(proc);
	else
		PB_Terminal.curProcess := process;
	fi;

	PB_ResetProcess(process);
	process.timeStamp := PB_GetTime();
	PB_Perform(process, function(proc)
		PB_PrintProgress(proc);
	end);

	return process;
end);

InstallGlobalFunction("UpdateProcess", function(args...)
	local root, process, t, dt, proc, child;

	# process arguments
	root := PB_Process;
	process := PB_Process;
	if Length(args) > 0 then
		if IsString(args[1]) then
			process := PB_FindProcess(PB_Process, args[1]);
		else
			process := args[1];
		fi;
	fi;
	if Length(args) > 1 then
		process.title := args[2];
	fi;
	if Length(args) > 2 then
		process.options := args[3];
	fi;

	# time
	t := PB_GetTime();
	if process.timeStamp <> fail then
		dt := t - process.timeStamp;
		process.totalTime := process.totalTime + dt;
	fi;
	process.timeStamp := t;

	# increment step
	process.curStep := process.curStep + 1;

	# print
	for child in process.children do
		PB_ResetProcess(child);
	od;

	if IsBound(PB_Terminal.curProcess) and PB_Terminal.curProcess.id <> process.id then
		proc := PB_Terminal.curProcess;
		PB_Terminal.curProcess := process;
		PB_PrintProgress(proc);
	else
		PB_Terminal.curProcess := process;
	fi;

	PB_PrintProgress(process);

	# root process terminated
	if root.curStep >= root.nrSteps then
		PB_MoveCursorToLine(PB_Terminal.usedLines);
		PB_PrintNewLine();
		PB_ShowCursor();
		PB_Process := fail;
		PB_Terminal := fail;
	fi;

	return process;
end);

InstallGlobalFunction("PB_ResetProcess", function(process)
	PB_Perform(process, function(proc)
		process.totalTime := 0;
		process.timeStamp := fail;
		process.curStep := 0;
	end);
end);
