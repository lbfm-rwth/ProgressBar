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