#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  ProgressPrinter.gi
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


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Progress Printer : Options
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# Default options, immutable entries
BindGlobal("PB_DisplayOptionsDefault", Immutable(rec(
	# print bool options
	printID := false,
    printTotalTime := false,
	printTotalTimeOnlyForRoot := true,
	printETA := false,
	printETAOnlyForRoot := true,
	highlightCurStep := false,
	highlightColor := "red",
	highlightStyle := "default",
	# print symbols
	separator := " | ",
	branch := "|  ",
	bar_prefix := "[",
	bar_symbol_full := "=",
	bar_symbol_empty := "-",
	bar_suffix := "]",
)));

# Current options, mutable entries
BindGlobal("PB_DisplayOptions", ShallowCopy(PB_DisplayOptionsDefault));

InstallGlobalFunction( DisplayOptionsOfProgressPrinter,
function()
    Display(PB_DisplayOptions);
end);

# TODO: Setting Display Options should also change the pattern
InstallGlobalFunction(SetDisplayOptionsOfProgressPrinter,
function(options)
    PB_SetOptions(PB_DisplayOptions, options);
end);

InstallGlobalFunction(ResetDisplayOptionsOfProgressPrinter,
function()
    SetDisplayOptionsOfProgressPrinter(PB_DisplayOptionsDefault);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Progress Printer : Layout
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


PB_Global.ProgressPrinter.LayoutOptionsDefault := Immutable(rec(
	alignment := "horizontal",
	sync := [],
));

PB_Global.ProgressPrinter.Layout := rec(
	id := "process",
	layout_options := rec(),
	isActive := ReturnTrue,
	children := [
	rec(
		id := "left",
		layout_options := rec(),
		isActive := ReturnTrue,
		printer := PB_IndentPrinter,
		printer_options := rec(
			branch := PB_DisplayOptions.branch
		)
	),
	rec(
		id := "right",
		layout_options := rec(),
		isActive := ReturnTrue,
		children := [
		rec(
			id := "bottom line",
			layout_options := rec(),
			isActive := ReturnTrue,
			children := [
			rec(
				id := "progress bar",
				layout_options := rec(),
				isActive := ReturnTrue,
				printer := PB_ProgressBarPrinter,
				printer_options := rec(
					bar_prefix := PB_DisplayOptions.bar_prefix,
					bar_suffix := PB_DisplayOptions.bar_suffix,
					bar_symbol_empty := PB_DisplayOptions.bar_symbol_empty,
					bar_symbol_full := PB_DisplayOptions.bar_symbol_full,
				),
			),
			rec(
				id := "separator 1",
				layout_options := rec(),
				isActive := ReturnTrue,
				printer := PB_TextPrinter,
				printer_options := rec(
					text := PB_DisplayOptions.separator
				),
			),
			rec(
				id := "progress ratio",
				layout_options := rec(
					sync := ["w"]
				),
				isActive := ReturnTrue,
				printer := PB_ProgressRatioPrinter,
				printer_options := rec(),
			)
			]
		)
		]
	)
	]
);

PB_Global.ProgressPrinter.InitialConfigurationRecord := [];