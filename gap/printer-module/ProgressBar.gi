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


BindGlobal("PB_ProgressBarPrinter", rec());

PB_ProgressBarPrinter.dimensions := function(process, options)
    return rec(
        w := fail,
        h := 1
    );
end;

PB_ProgressBarPrinter.generate := function(process, id, options)
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
end;

PB_ProgressBarPrinter.refresh := function(process, id, options)
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
end;
