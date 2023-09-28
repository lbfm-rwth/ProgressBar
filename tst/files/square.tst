gap> ReadPackage("ProgressBar", "tst/shapes.g");
gap> ResetTerminal();;
gap> PrintSquare(5, "=");
==========
=        =
=        =
=        =
==========
gap> ResetTerminal();;
gap> PrintSquare(6, "O");
OOOOOOOOOOOO
O          O
O          O
O          O
O          O
OOOOOOOOOOOO
gap> ResetTerminal();;
gap> PrintSquare(9, "*");
******************
*                *
*                *
*                *
*                *
*                *
*                *
*                *
******************
gap> ResetTerminal();;
gap> PrintDots(10, 10, "o");
o o o o o o o o o o
o o o o o o o o o o
o o o o o o o o o o
o o o o o o o o o o
o o o o o o o o o o
o o o o o o o o o o
o o o o o o o o o o
o o o o o o o o o o
o o o o o o o o o o
o o o o o o o o o o
