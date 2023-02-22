#############################################################################
##  ProgressBar.gd
#############################################################################
##
##  This file is part of the ProgressBar package.
##
##  This file's authors include Friedrich Rober.
##
##  Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
#############################################################################


#############################################################################
# Display
#############################################################################


## <#GAPDoc Label="DisplayOptionsForProgressBar">
## <ManSection>
## <Func Name="DisplayOptionsForProgressBar" Arg=""/>
## <Description>
##   prints the current global display options for progress bar.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "DisplayOptionsForProgressBar" );

## <#GAPDoc Label="SetDisplayOptionsForProgressBar">
## <ManSection>
## <Func Name="SetDisplayOptionsForProgressBar" Arg="optrec"/>
## <Description>
##   sets the current global display options for progress bar. <P/>
##   The argument <A>optrec</A> must be a record with components that are valid display options. (see <Ref Label="Display Functions"/>)
##   The components for the current global display options are set to the values specified by the components in <A>optrec</A>.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "SetDisplayOptionsForProgressBar" );

## <#GAPDoc Label="ResetDisplayOptionsForProgressBar">
## <ManSection>
## <Func Name="ResetDisplayOptionsForProgressBar" Arg=""/>
## <Description>
##   resets the current global display options for progress bar to default.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "ResetDisplayOptionsForProgressBar" );


#############################################################################
# Progress Bar
#############################################################################


## <#GAPDoc Label="DeclareProcess">
## <ManSection>
## <Func Name="DeclareProcess" Arg="nrSteps[, parent, id][, title][, optrec]"/>
## <Description>
##   Call this function to declare a process. <P/>
##   Returns the declared process. (see Chapter  <Ref Chap="Intro"/> for examples) <P/>
##   The argument <A>nrSteps</A> indicates the number of steps needed for the process to terminate.
##   If just called with the argument <A>nrSteps</A>,
##   the process will be declared as the root and be given an automatic id. <P/>
##   The optional argument <A>parent</A> must either be a process record,
##   the id (string) of a valid process, or <C>fail</C> to declare the process as the root. <P/>
##   The optional argument <A>id</A> must be a unique string for the process. <P/>
##   The optional argument <A>title</A> must be a string or <C>fail</C>.
##   If specified, the title will be printed in the progress bar. <P/>
##   The optional argument <A>optrec</A> must be a record with components that are valid display options.
##   (see <Ref Label="Display Functions"/>)
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "DeclareProcess" );

## <#GAPDoc Label="StartProcess">
## <ManSection>
## <Func Name="StartProcess" Arg="process"/>
## <Func Name="StartProcess" Arg="nrSteps[, parent, id][, title][, optrec]"/>
## <Description>
##   Call this function before the start of a process.
##   (For example exactly in the line above the <C>for</C> keyword in a loop) <P/>
##   Returns the started process (see Chapter <Ref Chap="Intro"/> for examples) <P/>
##   If the process has already been declared, one can call this function with only one argument <A>process</A>,
##   which must be either a process record or the id (string) of a valid process.
##   Otherwise one has to use the function with arguments as specified
##   in <Ref Func="DeclareProcess"/> to declare the process.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "StartProcess" );

## <#GAPDoc Label="UpdateProcess">
## <ManSection>
## <Func Name="UpdateProcess" Arg=""/>
## <Func Name="UpdateProcess" Arg="process[, title][, optrec]"/>
## <Description>
##   Call this function at the end of a step of the given process.
##   (For example exactly in the line above the <C>od;</C> keyword in a loop) <P/>
##   Returns the updated process (see Chapter <Ref Chap="Intro"/> for examples) <P/>
##   The optional argument <A>process</A> must either be a process record or
##   the id (string) of a valid process. <P/>
##   If not specified, <A>process</A> will be set to the root process.
##   The optional argument <A>title</A> must be string or <C>fail</C>.
##   If specified, the title of the process gets updated
##   and will be printed in the prograss bar. <P/>
##   The optional argument <A>optrec</A> must be a record with components that are valid display options.
##   (see Section <Ref Label="Display Functions"/>)
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "UpdateProcess" );


#############################################################################
# Recursive Helper Functions
#############################################################################


DeclareGlobalFunction( "PB_ResetProcess" );
DeclareGlobalFunction( "PB_FindProcess" );
DeclareGlobalFunction( "PB_AddBranchToChildren" );
DeclareGlobalFunction( "PB_ProcessTime" );
DeclareGlobalFunction( "PB_MaxProcess" );
DeclareGlobalFunction( "PB_PrintProgress" );
