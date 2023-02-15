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


PP_TotalTime := 0;

PP_LastTime := 0;


#############################################################################
# Helper Functions
#############################################################################


# returns number of digits
BindGlobal("PP_NrDigits", function(x)
	if x = 0 then
		return 1;
	else
		return LogInt(x, 10) + 1;
	fi;
end);

# returns string representation of length n
# by appending leading zeros to the digit x if necessary
BindGlobal("PP_StrDigit", function(x, n)
	local nr_digits;
	nr_digits := PP_NrDigits(x);
	if x = 0 then
		return Concatenation(ListWithIdenticalEntries(n, "0"));
	else
		return Concatenation(Concatenation(ListWithIdenticalEntries(n - nr_digits, "0")), String(x));
	fi;
end);

# returns time in milliseconds after epoch
BindGlobal("PP_GetTime", function()
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

# convert milliseconds to h:min:s:ms
# args: t, printMS
BindGlobal("PP_ConvertTime", function(args...)
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
	# convert time decimals to string
	h := String(h, 1);
	min := PP_StrDigit(min, 2);
	sec := PP_StrDigit(sec, 2);
	ms := PP_StrDigit(ms, 3);
	# compose string
	if printMS then
		return JoinStringsWithSeparator([h, min, sec, ms], ":");
	else
		return JoinStringsWithSeparator([h, min, sec], ":");
	fi;
end);


#############################################################################
# Progress Bar
#############################################################################


InstallGlobalFunction("StartProgress", function();
	PP_TotalTime := 0;
	PP_LastTime := PP_GetTime();
end);

InstallGlobalFunction("EndProgress", function();
	Print("Terminated after ", PP_ConvertTime(PP_TotalTime));
end);

InstallGlobalFunction("PrintProgress", function(i, nrIterations)
	local t, dt, widthScreen, bar_prefix, bar_symbol_full, bar_symbol_empty, bar_suffix,
	r, a, nr_digits, progress_percent, progress_ratio, progress_expected_time, progress_info,
	bar_length, bar_length_full, bar_length_empty;

	# time
	t := PP_GetTime();
	dt := t - PP_LastTime;
	PP_TotalTime := PP_TotalTime + dt;
	PP_LastTime := t;

	# progress bar parameters
	widthScreen := SizeScreen()[1] - 2;
	bar_prefix := " [";
	bar_symbol_full := "=";
	bar_symbol_empty := "-";
	bar_suffix := "] ";

	# progress info
	r := i / nrIterations;
	progress_percent := Concatenation(String(Int(r * 100), 3), "%");
	nr_digits := PP_NrDigits(nrIterations);
	progress_ratio := Concatenation(String(i, nr_digits), "/", String(nrIterations));
	a := PP_TotalTime / i;
	progress_expected_time := Concatenation("eta ", PP_ConvertTime(Int(a * (nrIterations - i))));
	progress_info := JoinStringsWithSeparator([progress_percent, progress_ratio, progress_expected_time], " | ");

	# progress bar length
	bar_length := widthScreen - Length(bar_prefix) - Length(bar_suffix) - Length(progress_info);
	bar_length_full := Int(bar_length * r);
	bar_length_empty := bar_length - bar_length_full;

	# print progress bar and info
	Print("\r");
	Print(bar_prefix);
	if bar_length_full > 0 then
		Print(Concatenation(ListWithIdenticalEntries(bar_length_full, bar_symbol_full)));
	fi;
	if bar_length_empty > 0 then
		Print(Concatenation(ListWithIdenticalEntries(bar_length_empty, bar_symbol_empty)));
	fi;
	Print(bar_suffix);
	Print(progress_info);
end);
