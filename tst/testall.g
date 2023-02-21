#
# ProgressBar: The GAP package ProgressBar displays the progression of a process in the terminal.
#
# This file runs package tests. It is also referenced in the package
# metadata in PackageInfo.g.
#
LoadPackage( "ProgressBar" );

TestDirectory(DirectoriesPackageLibrary( "ProgressBar", "tst" ),
  rec(exitGAP := true));

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
