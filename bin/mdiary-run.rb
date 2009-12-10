# coding: utf-8

#------------------------------------------
# mdiary-run.rb
# last: 2009-12-10
# ruby 1.9.1p376 
#------------------------------------------

dir = File.dirname(File.dirname(File.expand_path($PROGRAM_NAME)))
$LOAD_PATH.push(File.join(dir, 'bin'), File.join(dir, 'lib'))
$LOAD_PATH.delete(".")

load 'mdconfig', wrap=true
require 'mdiary'

start = Mdiary::Main.new().start
abort unless start
arg = ARGV
Mdiary::Main.new().command(arg)

