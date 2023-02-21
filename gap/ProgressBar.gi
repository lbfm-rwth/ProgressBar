#############################################################################
##  ProgressBar.gi
#############################################################################
##
##  This file is part of the ProgressBar package.
##
##  This file's authors include Friedrich Rober.
##
##  Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
#############################################################################


#############################################################################
# Global Variables
#############################################################################


PB_Process := fail;
PB_NrLines := 0;


#############################################################################
# Helper Functions
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

# returns time in milliseconds after epoch
BindGlobal("PB_GetTime", function()
	local path, python, t, out;

	path := DirectoriesSystemPrograms();
	python := Filename(path, "python");
	t := "";;
	out := OutputTextString(t, true);;
	Process(DirectoryCurrent(), python, InputTextNone(), out, ["-c", "from time import time; print(int(round(time() * 1000)))"]);
	CloseStream(out);
	NormalizeWhitespace(t);
	return Int(t);
end);

# returns string representation of a time given in milliseconds.
# The string is of the form `h:min:s` e.g. `01:23:42`
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

InstallGlobalFunction("PB_ProcessTime", function(process)
	local t, child;
	t := process.totalTime;
	for child in process.children do
		t := t + PB_ProcessTime(child);
	od;
	return t;
end);

InstallGlobalFunction("PB_MaxProcess", function(process)
	local m, child;
	m := process.nrSteps;
	for child in process.children do
		m := Maximum(m, PB_MaxProcess(child));
	od;
	return m;
end);

InstallGlobalFunction("PB_FindProcess", function(process, id)
	local child, res;
	if process.id = id then
		return process;
	fi;
	for child in process.children do
		res := PB_FindProcess(child, id);
		if res <> fail then
			return res;
		fi;
	od;
	return fail;
end);


#############################################################################
# Display Options
#############################################################################


# Default options, immutable entries
BindGlobal( "PB_DisplayOptionsDefault", Immutable(rec(
	# print bool options
    printTotalTime := false,
	printETA := true,
	removeChildren := true,
	highlightCurStep := false,
	highlightColor := "red",
	# print symbols
	separator := " | ",
	branch := " | ",
	bar_prefix := " [",
	bar_symbol_full := "=",
	bar_symbol_empty := "-",
	bar_suffix := "] ",
)));

# Current options, mutable entries
BindGlobal( "PB_DisplayOptions", ShallowCopy(PB_DisplayOptionsDefault));

InstallGlobalFunction( DisplayOptionsForProgressBar,
function()
    Display(PB_DisplayOptions);
end);

BindGlobal( "PB_SetDisplayOptions",
function(optionsBase, optionsUpdate)
    local r;
    for r in RecNames(optionsUpdate) do
        if not IsBound(optionsBase.(r)) then
            ErrorNoReturn("Invalid option for Progress Bar: ", r);
        fi;
		optionsBase.(r) := optionsUpdate.(r);
    od;
end);

BindGlobal("WPE_SetFont",
function(options)
    # Color
    if options.highlightColor = "red" then
        WriteAll(STDOut, "\033[31m");
    elif options.highlightColor = "blue" then
        WriteAll(STDOut, "\033[34m");
    fi;
end);


InstallGlobalFunction( SetDisplayOptionsForProgressBar,
function(options)
    PB_SetDisplayOptions(PB_DisplayOptions, options);
end);

InstallGlobalFunction( ResetDisplayOptionsForProgressBar,
function()
    SetDisplayOptionsForProgressBar(PB_DisplayOptionsDefault);
end);


#############################################################################
# Progress Bar
#############################################################################


BindGlobal("PB_PrintProcess", function(caller, options)
	local root, _;

	root := PB_Process;

	# progress bar parameters
	options.widthScreen := SizeScreen()[1] - 1;
	options.nr_digits := PB_NrDigits(PB_MaxProcess(root));

	# print progress bar and info
	for _ in [1 .. PB_NrLines - 1] do
		WriteAll(STDOut, "\033[2K"); # erase the entire line
		WriteAll(STDOut, "\033[1A"); # moves cursor up one line
	od;
	WriteAll(STDOut, "\033[2K"); # erase the entire line
	WriteAll(STDOut, "\r"); # move cursor to the start of the line

	PB_NrLines := PB_PrintProgress(caller, root, options);
end);

InstallGlobalFunction("PB_PrintProgress", function(caller, process, options)
	local root, curStep, nrSteps, totalTime, title, level, branches, nrLines, parent, indent, i,
	r, a, nr_digits, progress_percent, progress_ratio, progress_expected_time, progress_info,
	bar_length, bar_length_full, bar_length_empty, child;

	# initialization
	root := PB_Process;
	curStep := process.curStep;
	nrSteps := process.nrSteps;
	totalTime := process.totalTime;
	title := process.title;
	level := process.level;
	branches := process.branches;
	nrLines := 0;

	# is process finished?
	if curStep >= nrSteps then
		curStep := nrSteps;
	fi;

	# init indent
	if level = 0 then
		indent := "";
	else
		indent := Concatenation(ListWithIdenticalEntries(Length(options.branch), " "));
		indent := ListWithIdenticalEntries(level, indent);
		for i in branches do
			indent[i + 1] := options.branch;
		od;
		indent := Concatenation(indent);
	fi;

	# print headers and set font
	if level = 0 and options.printTotalTime then
		nrLines := nrLines + 1;
		WriteAll(STDOut, indent);
		WriteAll(STDOut, options.branch);
		WriteAll(STDOut, "Total Time ");
		WriteAll(STDOut, PB_StrTime(PB_ProcessTime(process)));
		WriteAll(STDOut, "\n");
	fi;

	if options.highlightCurStep and process = caller and not (process = root and curStep >= nrSteps) then
		WPE_SetFont(options);
	else
		WriteAll(STDOut, "\033[0m");
	fi;

	if title <> fail then
		nrLines := nrLines + 1;
		WriteAll(STDOut, indent);
		WriteAll(STDOut, options.branch);
		WriteAll(STDOut, title);
		WriteAll(STDOut, "\n");
	fi;

	# progress info
	progress_info := [];
	r := curStep / nrSteps;
	progress_percent := Concatenation(String(Int(r * 100), 3), "%");
	Add(progress_info, progress_percent);
	progress_ratio := Concatenation(String(curStep, options.nr_digits), "/", String(nrSteps));
	Add(progress_info, progress_ratio);
	if options.printETA then
		if curStep > 0 then
			a := totalTime / curStep;
			progress_expected_time := Concatenation("eta ", PB_StrTime(Int(a * (nrSteps - curStep))));
		else
			progress_expected_time := "eta ?:??:??";
		fi;
		Add(progress_info, progress_expected_time);
	fi;
	progress_info := JoinStringsWithSeparator(progress_info, options.separator);

	# progress bar length
	bar_length := options.widthScreen - Length(indent) - Length(options.bar_prefix) - Length(options.bar_suffix) - Length(progress_info);
	bar_length_full := Int(bar_length * r);
	bar_length_empty := bar_length - bar_length_full;

	# print progress bar
	nrLines := nrLines + 1;
	WriteAll(STDOut, indent);
	WriteAll(STDOut, options.bar_prefix);
	if bar_length_full > 0 then
		WriteAll(STDOut, Concatenation(ListWithIdenticalEntries(bar_length_full, options.bar_symbol_full)));
	fi;
	if bar_length_empty > 0 then
		WriteAll(STDOut, Concatenation(ListWithIdenticalEntries(bar_length_empty, options.bar_symbol_empty)));
	fi;
	WriteAll(STDOut, options.bar_suffix);
	WriteAll(STDOut, progress_info);

	WriteAll(STDOut, "\033[0m");

	# print progress of children
	if options.removeChildren and process = caller then
		process.children := [];
	fi;

	for child in process.children do
		WriteAll(STDOut, "\n");
		nrLines := nrLines + PB_PrintProgress(caller, child, options);
	od;

	return nrLines;
end);

InstallGlobalFunction("PB_ResetProcess", function(process)
	local child;
	process.totalTime := 0;
	process.lastTime := fail;
	process.curStep := 0;
	for child in process.children do
		PB_ResetProcess(child);
	od;
end);

InstallGlobalFunction("PB_AddBranch", function(process, level)
	local child;
	for child in process.children do
		Add(child.branches, level);
		PB_AddBranch(child, level);
	od;
end);

InstallGlobalFunction("DeclareProcess", function(args...)
	local root, nrSteps, parent, id, title, displayOptions, options, process, child, pos;

	# process arguments
	root := PB_Process;
	nrSteps := args[1];
	parent := fail;
	id := "pyqUyiFnuGQrWlkQrcbZoAFNDrZDZVPorcZihZAzRiufEfSTCBzzkGhzujIc";
	if Length(args) > 1 then
		if IsString(args[2]) then
			parent := PB_FindProcess(root, args[2]);
		else
			parent := args[2];
		fi;
		id := args[3];
	fi;
	title := fail;
	if Length(args) > 3 then
		title := args[4];
	fi;
	displayOptions := ShallowCopy(PB_DisplayOptions);
	if Length(args) > 4 then
		options := args[5];
		PB_SetDisplayOptions(displayOptions, options);
	fi;

	# create process
	process := rec(
		parent := parent,
		children := [],
		# total time of process at the start of current step
		totalTime := 0,
		# last time stamp of process at the start of current step
		lastTime := fail,
		# current step of process
		curStep := 0,
		# total number of steps for process to be marked as finished
		nrSteps := nrSteps,
		# id of process
		id := id,
		# title of step for process
		title := title,
		# level of process
		level := 0,
		# additional branches on the left of process
		branches := [],
	);

	if parent = fail then
		PB_NrLines := 0;
		PB_Process := process;
	else
		process.level := parent.level + 1;
		for child in parent.children do
			PB_AddBranch(child, process.level);
		od;
		pos := PositionProperty(parent.children, child -> child.title = title);
		if pos = fail then
			Add(parent.children, process);
		else
			process := parent.children[pos];
			PB_ResetProcess(process);
		fi;
	fi;

	return process;
end);

InstallGlobalFunction("StartProcess", function(args...)
	local root, displayOptions, options, process;

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

	process.lastTime := PB_GetTime();

	# print process
	displayOptions := ShallowCopy(PB_DisplayOptions);
	if Length(args) > 4 then
		options := args[5];
		PB_SetDisplayOptions(displayOptions, options);
	fi;

	PB_PrintProcess(process, displayOptions);

	return process;
end);

# ANSI Escape Sequences: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
InstallGlobalFunction("UpdateProcess", function(args...)
	local root, process, displayOptions, options, t, dt, child;

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
    displayOptions := ShallowCopy(PB_DisplayOptions);
	if Length(args) > 2 then
		options := args[3];
		PB_SetDisplayOptions(displayOptions, options);
	fi;

	# time
	t := PB_GetTime();
	dt := t - process.lastTime;
	process.totalTime := process.totalTime + dt;
	process.lastTime := t;

	# increment step
	process.curStep := process.curStep + 1;
	for child in process.children do
		PB_ResetProcess(child);
	od;

	# print
	PB_PrintProcess(process, displayOptions);

	# new line if root process terminated
	if root.curStep >= root.nrSteps then
		WriteAll(STDOut, "\n");
	fi;

	return process;
end);
