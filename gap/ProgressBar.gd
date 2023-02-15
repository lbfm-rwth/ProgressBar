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

## <#GAPDoc Label="StartProgress">
## <ManSection>
## <Func Name="StartProgress" Arg=""/>
## <Description>
##   Call this function before the start of the iteration process.
##   (see&nbsp;<Ref Sect="Intro Example"/>)
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "StartProgress" );


## <#GAPDoc Label="PrintProgress">
## <ManSection>
## <Func Name="PrintProgress" Arg="i, nrIterations"/>
## <Description>
##   Call this function at the end of the <A>i</A>-th iteration step.
##   (see&nbsp;<Ref Sect="Intro Example"/>)
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "PrintProgress" );

## <#GAPDoc Label="EndProgress">
## <ManSection>
## <Func Name="EndProgress" Arg=""/>
## <Description>
##   Call this function after the end of the iteration process.
##   (see&nbsp;<Ref Sect="Intro Example"/>)
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction( "EndProgress" );
