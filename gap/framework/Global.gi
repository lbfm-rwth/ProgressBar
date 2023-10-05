#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Global.gi
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
	ProgressPrinter := rec(),
	Alphabet := fail,
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
## Helper Functions
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


BindGlobal("PB_SetOptions",
function(optionsBase, optionsUpdate)
    local r;
    for r in RecNames(optionsUpdate) do
        if not IsBound(optionsBase.(r)) then
            ErrorNoReturn("Invalid option: ", r);
        fi;
		optionsBase.(r) := optionsUpdate.(r);
    od;
end);

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

# returns record rec(d, h, min, s, ms) encoding the time period t given in milliseconds.
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
