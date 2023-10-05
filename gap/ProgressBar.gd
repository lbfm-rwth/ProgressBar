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
##  Display
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


## <#GAPDoc Label="DisplayOptionsOfProgressPrinter">
## <ManSection>
## <Func Name="DisplayOptionsOfProgressPrinter" Arg=""/>
## <Description>
##   Prints the current global display options for progress bar.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "DisplayOptionsOfProgressPrinter" );

## <#GAPDoc Label="SetDisplayOptionsOfProgressPrinter">
## <ManSection>
## <Func Name="SetDisplayOptionsOfProgressPrinter" Arg="optrec"/>
## <Description>
##   Sets the current global display options for progress bar. <P/>
##   The argument <A>optrec</A> must be a record with components that are valid display options, see Section <Ref Sect="Display Functions"/>.
##   The components for the current global display options are set to the values specified by the components in <A>optrec</A>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "SetDisplayOptionsOfProgressPrinter" );

## <#GAPDoc Label="ResetDisplayOptionsOfProgressPrinter">
## <ManSection>
## <Func Name="ResetDisplayOptionsOfProgressPrinter" Arg=""/>
## <Description>
##   Resets the current global display options for progress bar to default.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "ResetDisplayOptionsOfProgressPrinter" );


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
##   Returns an iterator that behaves the same way as <A>iter</A>
##   and displays the progression of the iteration in the terminal,
##   see Chapter <Ref Chap="Intro"/> for examples. <P/>
##   The argument <A>iterLike</A> must be either
##   in the filters <C>IsListOrCollection</C> or <C>IsIterator</C>,
##   or a record with entries <C>(iter, nrSteps)</C>
##   where <C>iter</C> is in the filter <C>IsIterator</C>
##   and <C>nrSteps</C> is the number of times we have to call <C>NextIterator</C>
##   until <C>IsDoneIterator</C> returns <C>true</C>. <P/>
##   The optional argument <A>id</A> must be a
##   unique string identifier for the process.
##   If no <A>id</A> is provided, this process is declared as the root
##   and is assigned a random identifier. <P/>
##   The optional argument <A>parent</A> must either be a process iterator,
##   a process record, the id of a valid process,
##   or <C>fail</C> to declare the process as the root. <P/>
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
## <Func Name="SetProcess" Arg="nrSteps[, id[, parent[, content]]]"/>
## <Description>
##   Returns a (new) process whose parameters are set to the given arguments,
##   see Chapter <Ref Chap="Intro"/> for examples. <P/>
##   The argument <A>nrSteps</A> indicates the number of steps
##   needed for the process to terminate.
##   May be set to <C>infinity</C> if the number of steps is not known.
##   In this case, the process has to be terminated manually
##   via <Ref Func="EndProcess"/>. <P/>
##   For the specifications and default values of the other arguments,
##   see <Ref Func="ProcessIterator"/>. <P/>
##   If a process with the given <A>id</A> under <A>parent</A> already exists,
##   this resets the process
##   and sets <A>nrSteps</A> and <A>content</A> to the given arguments afterwards,
##   see <Ref Func="ResetProcess"/>. <P/>
##   Otherwise this creates a new process under <A>parent</A> with identifier <A>id</A>.
##   In particular if the parent is set to <C>fail</C>,
##   this will always create a new process and set it as the root.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "SetProcess" );

## <#GAPDoc Label="UpdateProcess">
## <ManSection>
## <Func Name="UpdateProcess" Arg="process[, content]"/>
## <Description>
##   This function increments the current step count of the given process,
##   updates the content of the process,
##   and refreshes the process, see <Ref Func="RefreshProcess"/>. <P/>
##   Call this function at the end of each iteration step.
##   A process is initialized at step -1. This special step indicates
##   that the process hasn't started yet. Thus iteration step -1 ends when the process starts,
##   see Chapter <Ref Chap="Intro"/> for examples. <P/>
##   The argument <A>process</A>  must either be a process iterator,
##   a process record, or the id of a valid process. <P/>
##   For the specifications and default values of the other arguments, see <Ref Func="ProcessIterator"/>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "UpdateProcess" );

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

## <#GAPDoc Label="ResetProcess">
## <ManSection>
## <Func Name="ResetProcess" Arg="process"/>
## <Description>
##   This function resets <A>process</A> and all its descendants to the initial state. <P/>
##   The argument <A>process</A>  must either be a process iterator,
##   a process record, or the id of a valid process.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "ResetProcess" );

## <#GAPDoc Label="StopProcess">
## <ManSection>
## <Func Name="StopProcess" Arg="process"/>
## <Description>
##   This function stops the timing of <A>process</A> and all its descendants. <P/>
##   The argument <A>process</A>  must either be a process iterator,
##   a process record, or the id of a valid process. <P/>
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "StopProcess" );

## <#GAPDoc Label="StartProcess">
## <ManSection>
## <Func Name="StartProcess" Arg="process"/>
## <Description>
##   This function resumes the timing of <A>process</A> and all its descendants. <P/>
##   The argument <A>process</A>  must either be a process iterator,
##   a process record, or the id of a valid process. <P/>
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "StartProcess" );

## <#GAPDoc Label="EndProcess">
## <ManSection>
## <Func Name="EndProcess" Arg="process"/>
## <Description>
##   This function terminates <A>process</A> and all its descendants. <P/>
##   The argument <A>process</A>  must either be a process iterator,
##   a process record, or the id of a valid process. <P/>
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "EndProcess" );

DeclareGlobalFunction( "PB_PrintProgress" );


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Printer Modules
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


DeclareGlobalName( "PB_IndentPrinter" );
DeclareGlobalName( "PB_ProgressBarPrinter" );
DeclareGlobalName( "PB_ProgressRatioPrinter" );
DeclareGlobalName( "PB_TextPrinter" );


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Recursive Helper Functions
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


DeclareGlobalFunction( "PB_First" );
DeclareGlobalFunction( "PB_Reduce" );
DeclareGlobalFunction( "PB_Perform" );
DeclareGlobalFunction( "PB_ChildrenAndSelf" );
DeclareGlobalFunction( "PB_UpperUntilCaller" );
DeclareGlobalFunction( "PB_PrintBlock" );
DeclareGlobalFunction( "PB_InitializeParent" );
DeclareGlobalFunction( "PB_InitializeDimension" );
DeclareGlobalFunction( "PB_InitializeVariables" );
DeclareGlobalFunction( "PB_AlignBlock" );
DeclareGlobalFunction( "PB_SetBounds" );
