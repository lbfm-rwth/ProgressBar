#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  ProgressBar.gd
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
##  ProgressPrinter
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


DeclareGlobalVariable("ProgressPrinter");
DeclareGlobalFunction( "PB_StartProgressPrinter" );

# Printing
DeclareGlobalFunction( "PB_PrintProgress" );
DeclareGlobalFunction( "PB_PrintProcess" );
DeclareGlobalFunction( "PB_PrintBlock" );

# Allocation
DeclareGlobalFunction( "PB_InitializeParent" );
DeclareGlobalFunction( "PB_SetupDimensionsConfiguration" );
DeclareGlobalFunction( "PB_SetupVariables" );
DeclareGlobalFunction( "PB_SetupAlignmentConfiguration" );
DeclareGlobalFunction( "PB_SetupBlocks" );
DeclareGlobalFunction( "PB_SetBounds" );

## <#GAPDoc Label="SetLayout">
## <ManSection>
## <Func Name="SetLayout" Arg="layout"/>
## <Description>
##   Sets the layout of the progress printer. <P/>
##   See Chapter <Ref Chap="Layouts"/> for a list of available layouts.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "SetLayout" );

## <#GAPDoc Label="LayoutOptions">
## <ManSection>
## <Func Name="LayoutOptions" Arg=""/>
## <Description>
##   Prints the layout options of the progress printer.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "LayoutOptions" );

## <#GAPDoc Label="SetLayoutOptions">
## <ManSection>
## <Func Name="SetLayoutOptions" Arg="optrec"/>
## <Description>
##   Sets the layout options of the progress printer. <P/>
##   The argument <A>optrec</A> must be a record with components that are valid options for the current layout, see Chapter <Ref Chap="Layouts"/>.
##   The components for the layout options are set to the values specified by the components in <A>optrec</A>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "SetLayoutOptions" );

## <#GAPDoc Label="ResetLayoutOptions">
## <ManSection>
## <Func Name="ResetLayoutOptions" Arg=""/>
## <Description>
##   Resets the layout options of the progress printer to default.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "ResetLayoutOptions" );


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Process
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


## <#GAPDoc Label="ProcessIterator">
## <ManSection>
## <Func Name="ProcessIterator" Arg="iterLike[, id[, parent[, content]]]"/>
## <Description>
##   Returns an iterator that behaves the same way as <A>iterLike</A>
##   and displays the progression of the iteration in the terminal,
##   see Chapter <Ref Chap="Intro"/> for examples. <P/>
##   The argument <A>iterLike</A> must be either
##   in the filter <C>IsListOrCollection</C> or <C>IsIterator</C>,
##   or be a record with entries <C>(iter, totalSteps)</C>
##   where <C>iter</C> is in the filter <C>IsIterator</C>
##   and <C>totalSteps</C> is the number of times we have to call <C>NextIterator</C>
##   until <C>IsDoneIterator</C> returns <C>true</C>. <P/>
##   The optional argument <A>id</A> must be a
##   unique string identifier for the process.
##   If no <A>id</A> is provided, this process is declared as the root
##   and is assigned a random identifier. <P/>
##   The optional argument <A>parent</A> must either be a process iterator,
##   a process record, the id of a valid process,
##   or <C>fail</C> to declare the process as the root. It is set to <C>fail</C> by default. <P/>
##   The optional argument <A>content</A> must be a record,
##   that contains additional information for the printer,
##   possibly about the progress of the process,
##   see Chapter <Ref Chap="Progress Printer"/>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "ProcessIterator" );

## <#GAPDoc Label="SetProcess">
## <ManSection>
## <Func Name="SetProcess" Arg="totalSteps[, id[, parent[, content]]]"/>
## <Description>
##   Returns a (new) process whose parameters are set to the given arguments,
##   see Chapter <Ref Chap="Intro"/> for examples. <P/>
##   The argument <A>totalSteps</A> indicates the number of steps
##   needed for the process to terminate.
##   May be set to <C>infinity</C> if the number of steps is not known.
##   In this case, the process has to be terminated manually
##   via <Ref Func="TerminateProcess"/>. <P/>
##   For the specifications and default values of the other arguments,
##   see <Ref Func="ProcessIterator"/>. <P/>
##   If a process with the given <A>id</A> under <A>parent</A> already exists,
##   this resets the process
##   and sets <A>totalSteps</A> and <A>content</A> to the given arguments afterwards,
##   see <Ref Func="ResetProcess"/>. <P/>
##   Otherwise this creates a new process under <A>parent</A> with identifier <A>id</A>.
##   In particular if the parent is set to <C>fail</C>,
##   this will always create a new process and set it as the root.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "SetProcess" );

## <#GAPDoc Label="RefreshProcess">
## <ManSection>
## <Func Name="RefreshProcess" Arg="process"/>
## <Description>
##   This function updates the timers of the process and displays the progress in the terminal. <P/>
##   The argument <A>process</A>  must either be a process iterator,
##   a process record, or the id of a valid process.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "RefreshProcess" );

## <#GAPDoc Label="UpdateProcess">
## <ManSection>
## <Func Name="UpdateProcess" Arg="process[, content[, doRefresh]]"/>
## <Description>
##   This function progresses the process.
##   Call this function at the end of each step,
##   see Chapter <Ref Chap="Intro"/> for examples. <P/>
##   The argument <A>process</A>  must either be a process iterator,
##   a process record, or the id of a valid process. <P/>
##   The optional argument <A>doRefresh</A> is a boolean indicating
##   whether <Ref Func="RefreshProcess"/> should be called afterwards.
##   It is set to <C>true</C> by default. <P/>
##   For the specifications and default values of <A>content</A>, see <Ref Func="ProcessIterator"/>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "UpdateProcess" );

## <#GAPDoc Label="ResetProcess">
## <ManSection>
## <Func Name="ResetProcess" Arg="process[, doRefresh]"/>
## <Description>
##   This function resets <A>process</A> and all its descendants to the initial state. <P/>
##   For the specifications and default values of the arguments, see <Ref Func="UpdateProcess"/>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "ResetProcess" );

## <#GAPDoc Label="StopProcess">
## <ManSection>
## <Func Name="StopProcess" Arg="process[, doRefresh]"/>
## <Description>
##   This function stops the timing of <A>process</A> and all its descendants. <P/>
##   For the specifications and default values of the arguments, see <Ref Func="UpdateProcess"/>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "StopProcess" );

## <#GAPDoc Label="StartProcess">
## <ManSection>
## <Func Name="StartProcess" Arg="process[, doRefresh]"/>
## <Description>
##   This function starts/resumes the timing of <A>process</A> and all its descendants. <P/>
##   For the specifications and default values of the arguments, see <Ref Func="UpdateProcess"/>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "StartProcess" );

## <#GAPDoc Label="TerminateProcess">
## <ManSection>
## <Func Name="TerminateProcess" Arg="process[, doRefresh]"/>
## <Description>
##   This function terminates <A>process</A> and all its descendants. <P/>
##   For the specifications and default values of the arguments, see <Ref Func="UpdateProcess"/>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "TerminateProcess" );


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Printer Modules
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


DeclareGlobalName( "PB_HighlightPrinter" );
DeclareGlobalName( "PB_TreeBranchesPrinter" );
DeclareGlobalName( "PB_ProgressBarPrinter" );
DeclareGlobalName( "PB_ProgressRatioPrinter" );
DeclareGlobalName( "PB_StaticInlinePrinter" );
DeclareGlobalName( "PB_DynamicMultilinePrinter" );
DeclareGlobalName( "PB_TotalTimeHeaderPrinter" );


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Terminal
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# Print
DeclareGlobalFunction( "PB_Print" );

# Style and Color
DeclareGlobalFunction( "PB_SetStyleAndColor" );
DeclareGlobalFunction( "PB_ResetStyleAndColor" );
DeclareGlobalFunction( "PB_SetStyle" );
DeclareGlobalFunction( "PB_SetForegroundColor" );
DeclareGlobalFunction( "PB_SetBackgroundColor" );

# Cursor Movement
DeclareGlobalFunction( "PB_MoveCursorToCoordinate" );
DeclareGlobalFunction( "PB_MoveCursorToStartOfLine" );
DeclareGlobalFunction( "PB_MoveCursorToProcessEnd" );
DeclareGlobalFunction( "PB_MoveCursorDown" );
DeclareGlobalFunction( "PB_MoveCursorUp" );
DeclareGlobalFunction( "PB_MoveCursorToLine" );
DeclareGlobalFunction( "PB_MoveCursorRight" );
DeclareGlobalFunction( "PB_MoveCursorLeft" );
DeclareGlobalFunction( "PB_MoveCursorToChar" );

# Cursor Visibility
DeclareGlobalFunction( "PB_HideCursor" );
DeclareGlobalFunction( "PB_ShowCursor" );

# Clearing
DeclareGlobalFunction( "PB_ClearScreen" );
DeclareGlobalFunction( "PB_ClearProcess" );
DeclareGlobalFunction( "PB_ClearBlock" );
DeclareGlobalFunction( "PB_ClearLine" );
DeclareGlobalFunction( "PB_RefreshLine" );


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Tree Traversal
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# Tree Manipulation
DeclareGlobalFunction( "PB_Reduce" );
DeclareGlobalFunction( "PB_Perform" );

# Tree Nodes
DeclareGlobalFunction( "PB_First" );
DeclareGlobalFunction( "PB_Last" );
DeclareGlobalFunction( "PB_List" );
DeclareGlobalFunction( "PB_Successors" );
DeclareGlobalFunction( "PB_Predecessors" );
DeclareGlobalFunction( "PB_Lower" );
DeclareGlobalFunction( "PB_Upper" );
DeclareGlobalFunction( "PB_Siblings" );

# Helpers
DeclareGlobalFunction( "PB_ChildrenAndSelf" );
DeclareGlobalFunction( "PB_UpperUntilCaller" );
