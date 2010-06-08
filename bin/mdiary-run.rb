#!/path/to/ruby19
# coding: utf-8

#------------------------------------------
# mdiary-run.rb
# ruby 1.9.1p376 

# 2010-06-02
# ruby 1.9.2dev (2010-05-31 revision 28117) [x86_64-darwin10.3.0]
#------------------------------------------

exit unless Encoding.default_external.name == 'UTF-8'
dir = File.dirname(File.dirname(File.expand_path($PROGRAM_NAME)))
bin = File.join(dir, 'bin')
lib = File.join(dir, 'lib')
$LOAD_PATH.push(bin, lib)
$LOAD_PATH.delete(".")

arg = ARGV
arg.delete("")
require 'mdiary/mdiary-arg'
require 'time'

# check arg
err, arg_h = Mdiary::CheckStart.new(arg).base
exit if err == 'help'
(print "#{err}\n"; exit) if err

# load conf
conf = File.join(bin, 'mdconfig')
exit unless File.exist?(conf)

# start
load conf, wrap=true
require 'mdiary'
Mdiary::Main.new().start(arg_h)

