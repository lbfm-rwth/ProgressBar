[![CI](https://github.com/lbfm-rwth/ProgressBar/workflows/CI/badge.svg)](https://github.com/lbfm-rwth/ProgressBar/actions?query=workflow%3ACI+branch%3Amaster)
[![Code Coverage](https://codecov.io/gh/lbfm-rwth/ProgressBar/coverage.svg?branch=master&token=)](https://codecov.io/gh/lbfm-rwth/ProgressBar)


# The GAP package ProgressBar

The GAP package ProgressBar displays the progression of a process in the terminal.

## Demonstration : Loop

A demonstration of the simplest use case of the package,
namely displaying the process of a loop.

![](https://github.com/lbfm-rwth/ProgressBar/blob/main/gif/loop_light.gif#gh-light-mode-only)![](https://github.com/lbfm-rwth/ProgressBar/blob/main/gif/loop_dark.gif#gh-dark-mode-only)

## Demonstration : Steps

A demonstration of displaying the progress inside a function.

![](https://github.com/lbfm-rwth/ProgressBar/blob/main/gif/steps_light.gif#gh-light-mode-only)![](https://github.com/lbfm-rwth/ProgressBar/blob/main/gif/steps_dark.gif#gh-dark-mode-only)

## Demonstration : Tree

A demonstration of displaying a progress tree

![](https://github.com/lbfm-rwth/ProgressBar/blob/main/gif/tree_light.gif#gh-light-mode-only)![](https://github.com/lbfm-rwth/ProgressBar/blob/main/gif/tree_dark.gif#gh-dark-mode-only)

## Installation

**1.** To get the newest version of this GAP 4 package download the archive file `ProgressBar-x.x.tar.gz` from
>   <https://lbfm-rwth.github.io/ProgressBar/>

**2.** Locate a `pkg/` directory where GAP searches for packages, see
>   [9.2 GAP Root Directories](https://www.gap-system.org/Manuals/doc/ref/chap9.html#X7A4973627A5DB27D)

in the GAP manual for more information.

**3.** Unpack the archive file in such a `pkg/` directory
which creates a subdirectory called `ProgressBar/`.

**4.** Now you can use the package within GAP by entering `LoadPackage("ProgressBar");` on the GAP prompt.

## Documentation

You can read the documentation online at
>   <https://lbfm-rwth.github.io/ProgressBar/doc/chap0.html>

If you want to access it from within GAP by entering `?ProgressBar` on the GAP prompt,
you first have to build the manual by using `gap makedoc.g` from within the `ProgressBar/` root directory.

## Bug reports

Please submit bug reports, feature requests and suggestions via our issue tracker at
>  <https://github.com/lbfm-rwth/ProgressBar/issues>

## License

ProgressBar is free software you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. For details, see the file LICENSE distributed as part of this package or see the FSF's own site.
