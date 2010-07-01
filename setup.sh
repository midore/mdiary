#!/bin/bash
# 2010-06-30

# data and conf directory
dir=$HOME/.m_diary
echo $dir

mkdir $dir
mkdir $dir/trash $dir/text $dir/scpt

# If you don't want to use osacompilethis command in "Terminal.app".
# $ open open-vim.applescript in "AppleScrptEditor.app"

# If you like emacs, edit a file $ emacs open-vim.applescript
osacompile -o $dir/scpt/openvim.scpt  open-vim.applescript
# mv a.scpt $dir/scpt/openvim.scpt

# conf file
cp mdiary_conf $dir/mdiary_conf

