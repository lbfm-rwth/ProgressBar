#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  DynamicMultiline.gi
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


BindGlobal("PB_DynamicMultilinePrinter", rec());

PB_DynamicMultilinePrinter.dimensions := function(process, options)
	return rec(
		w := fail,
		h := fail
	);
end;

PB_DynamicMultilinePrinter.generate := function(process, id, options)
	local block, chunks, buffer, char, word, j;
	block := process.blocks.(id);
    chunks := [];
    buffer := "";
    for char in options.text do
        if char = ' ' then
            Add(chunks, buffer);
            Add(chunks, " ");
            buffer := "";
        else
            Add(buffer, char);
        fi;
    od;
    if buffer <> "" then
        Add(chunks, buffer);
    fi;

    # force a new line at the start
	PB_MoveCursorToCoordinate(block.x + block.w, block.y);
    j := 0;

    for word in chunks do
        if Length(word) + ProgressPrinter.Cursor.x > block.x + block.w then
            PB_MoveCursorToCoordinate(block.x, block.y + j);
            j := j + 1;
            # FIXME: How to deal with a block that is not large enough?
            if j > block.h then
                break;
            fi;
            PB_Print(options.prefix);
        fi;
        # FIXME: word too long
        if Length(word) + ProgressPrinter.Cursor.x > block.x + block.w then
            continue;
        fi;
	    PB_Print(word);
    od;
    block.text := options.text;
end;

PB_DynamicMultilinePrinter.update := function(process, id, options)
    local block;
    block := process.blocks.(id);
	if block.text <> options.text then
        PB_DynamicMultilinePrinter.generate(process, id, options);
    fi;
    return true;
end;
