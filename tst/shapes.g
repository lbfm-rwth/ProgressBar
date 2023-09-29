
# height: 2 * n
# width: n
PrintSquare := function(n, s)
    local i, ss;
    PB_ResetTerminal();
    ss := String(Concatenation(ListWithIdenticalEntries(2, s)));
    PB_Print(String(Concatenation(ListWithIdenticalEntries(n, ss))));
    for i in [2 .. n - 1] do
        PB_MoveCursorToCoordinate(1, i);
        PB_Print(s);
        PB_MoveCursorToCoordinate(2 * n, i);
        PB_Print(s);
    od;
    PB_MoveCursorToCoordinate(1, n);
    for i in [1 .. n] do
        PB_Print(ss);
    od;
    PB_PrintNewLine();
end;

# width: 2 * n - 1
# height: m
PrintDots := function(n, m, s)
    local i, j;
    PB_ResetTerminal();
    for i in [1 .. n] do
        for j in [1 .. m] do
            PB_MoveCursorToCoordinate(2 * i - 1, j);
            PB_Print(s);
        od;
    od;
    PB_PrintNewLine();
end;
