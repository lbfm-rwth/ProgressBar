#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  StaticInline.gi
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


BindGlobal("PB_StaticInlinePrinter", rec());

PB_StaticInlinePrinter.dimensions := function(process, options)
	return rec(
		w := Length(options.text),
		h := 1
	);
end;

PB_StaticInlinePrinter.generate := function(process, id, options)
	local block;
	block := process.blocks.(id);
	PB_MoveCursorToCoordinate(block.x, block.y);
	PB_Print(options.text);
end;

PB_StaticInlinePrinter.update := function(process, id, options)
	return true;
end;
