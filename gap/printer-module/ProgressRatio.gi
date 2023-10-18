#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  ProgressRatio.gi
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


BindGlobal("PB_ProgressRatioPrinter", rec());

PB_ProgressRatioPrinter.dimensions := function(process, options)
	local n;
	if IsInfinity(process.totalSteps) then
		n := Maximum(Length(options.inf), PB_NrDigits(Maximum(0, process.completedSteps)));
	else
		n := PB_NrDigits(process.totalSteps);
	fi;
	return rec(
		w := n * 2 + 1,
		h := 1
	);
end;

PB_ProgressRatioPrinter.generate := function(process, id, options)
	local block, completedSteps;
	block := process.blocks.(id);
	block.nr_digits := (block.w - 1) / 2;
	PB_MoveCursorToCoordinate(block.x, block.y);
	completedSteps := Maximum(0, process.completedSteps);
	PB_Print(String(completedSteps, block.nr_digits));
	PB_Print("/");
	if IsInfinity(process.totalSteps) then
		PB_Print(options.inf);
	else
		PB_Print(String(process.totalSteps, block.nr_digits));
	fi;
end;

PB_ProgressRatioPrinter.update := function(process, id, options)
	local block, nr_digits, completedSteps;
	block := process.blocks.(id);
	completedSteps := Maximum(0, process.completedSteps);
	nr_digits := PB_NrDigits(completedSteps);
	if nr_digits > block.nr_digits then
		return false;
	fi;
	PB_MoveCursorToCoordinate(block.x, block.y);
	PB_Print(String(completedSteps, block.nr_digits));
	return true;
end;
