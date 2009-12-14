#!/path/to/your/ruby191
# coding: utf-8

#------------------------------------------
# mdiary-run.rb
# last: 2009-12-14
# ruby 1.9.1p376 
#------------------------------------------

dir = File.dirname(File.dirname(File.expand_path($PROGRAM_NAME)))
$LOAD_PATH.push(File.join(dir, 'bin'), File.join(dir, 'lib'))
$LOAD_PATH.delete(".")

load 'mdconfig', wrap=true
require 'mdiary'

Mdiary::Main.new().start(ARGV)

