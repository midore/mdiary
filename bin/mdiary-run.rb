# coding: utf-8

#------------------------------------------
# mdiary-run.rb
# ruby 1.9.1p376 
# 2010-01-11
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

# check arg
st = Mdiary::CheckStart.new(arg)
st.base
err, arg_h = st.err, st.h

# error or help
exit if err == 'help'
(print "#{err}\n"; exit) unless err.nil?

# load conf
conf = File.join(bin, 'mdconfig')
exit unless File.exist?(conf)

# start
load conf, wrap=true
require 'mdiary'
Mdiary::Main.new().start(arg_h)

