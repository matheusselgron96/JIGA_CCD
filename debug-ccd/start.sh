#!/bin/bash

text_format_file="./scripts/text_format.lib"
. $text_format_file

echo -e "$bgblue Starting script! Programming board...$f"
./scripts/progboard.sh

echo -e "$bgblue Loading Qsys IP's addresses $f"
./scripts/make_qsys_header.sh
echo -e "$bgblue Openning System Console for input data ... $f"
system-console --desktop_script=./scripts/main_init.tcl
echo -e "$bgblue All set !$f"