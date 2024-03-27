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


BindGlobal("PB_ValuePrinter", rec());

PB_ValuePrinter.findSubstringStart := function(l, sub)
    local pos;
    for pos in [1 .. Length(l) - Length(sub) + 1] do
        if l{[pos .. pos + Length(sub) - 1]} = sub then
            return pos;
        fi;
    od;
    return fail;
end;

PB_ValuePrinter.value := fail;

PB_ValuePrinter.processString := function(l)
    local pos1, pos2, prefix, suffix, funcStr, pos;
    pos1 := PB_ValuePrinter.findSubstringStart(l, "{{");
    if pos1 = fail then
        return fail;
    fi;
    prefix := l{[1 .. pos1 - 1]};
    # note, we change pos2 directly afterwards
    pos2 := PB_ValuePrinter.findSubstringStart(l{[pos1 + 2 .. Length(l)]}, "}}");
    if pos2 = fail then
        return fail;
    fi;
    pos2 := pos1 + pos2 + 1; # convert to start in l
    funcStr := l{[pos1 + 2 .. pos2 - 1]};
    suffix := l{[pos2 + 2 .. Length(l)]};
    pos := PB_ValuePrinter.findSubstringStart(funcStr, "value");
    if pos = fail then
        return fail;
    fi;
    return rec(
        prefix := prefix,
        suffix := suffix,
        func := function(value)
            PB_ValuePrinter.value := value;
            return EvalString(ReplacedString(funcStr, "value", "PB_ValuePrinter.value"));
        end,
    );
end;

PB_ValuePrinter.dimensions := function(process, options)
    local lines;
    if not IsBound(process.content.(options.id)) then
        return rec(
            w := fail,
            h := fail
        );
    fi;
    lines := SplitString(process.content.(options.id), "\n");
    return rec(
        w := fail,
        h := Length(lines),
    );
end;

PB_ValuePrinter.generate := function(process, id, options)
    local block, lines, i, line, r;
    if not IsBound(process.content.(options.id)) then
        return;
    fi;
	block := process.blocks.(id);
    lines := SplitString(process.content.(options.id), "\n");
    for i in [1 .. Length(lines)] do
        PB_MoveCursorToCoordinate(block.x, block.y + i - 1);
        line := lines[i];
        r := PB_ValuePrinter.processString(line);
        PB_Print(options.prefix);
        if r = fail then
            PB_Print(line);
        else
            PB_Print(r.prefix);
            block.valueStartPos := rec(
                x := block.x + Length(options.prefix) + Length(r.prefix),
                y := block.y + i - 1);
            block.func := r.func;
            if IsBound(process.value) then
                block.value := String(block.func(process.value));
            else
                block.value := "N/A";
            fi;
            PB_Print(block.value);
            block.suffix := r.suffix;
            PB_Print(block.suffix);
        fi;
    od;
end;

PB_ValuePrinter.update := function(process, id, options)
    local block, value, pos;
    if not IsBound(process.content.(options.id)) then
        return true;
    fi;
    block := process.blocks.(id);
	if IsBound(process.value) then
        value := String(block.func(process.value));
    else
        value := "N/A";
    fi;
    pos := block.valueStartPos;
    if pos = fail then
        return true;
    fi;
    PB_MoveCursorToCoordinate(pos.x, pos.y);
    PB_Print(value);
    if Length(value) <> Length(block.value) then
        PB_Print(block.suffix);
    fi;
    block.value := value;
    return true;
end;
