#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  TotalTime.gi
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


BindGlobal("PB_TotalTimeHeaderPrinter", rec());

PB_TotalTimeHeaderPrinter.dimensions := function(process, options)
	return rec(
		w := fail,
		h := 1
	);
end;

PB_TotalTimeHeaderPrinter.setOptions := function(process, id, options)
    local timeRec, timeStr;
    timeRec := PB_TimeRecord(process.totalTime);
    timeStr := "Total Time ~ ";
    if timeRec.d > 0 then
        timeStr := Concatenation(timeStr, String(timeRec.d), "day(s) and ");
    fi;
    timeStr := Concatenation(timeStr, PB_StrNum(timeRec.h, 2), ":", PB_StrNum(timeRec.min, 2), ":", PB_StrNum(timeRec.s, 2));
	options.text := timeStr;
end;

PB_TotalTimeHeaderPrinter.generate := function(process, id, options)
    PB_TotalTimeHeaderPrinter.setOptions(process, id, options);
    PB_HeaderPrinter.generate(process, id, options);
end;

PB_TotalTimeHeaderPrinter.update := function(process, id, options)
    PB_TotalTimeHeaderPrinter.setOptions(process, id, options);
    return PB_HeaderPrinter.update(process, id, options);
end;
