# coding: utf-8

#------------------------------------------
# mdiary-run.rb
# last: 2009-12-19
# ruby 1.9.1p376 
#------------------------------------------

dir = File.dirname(File.dirname(File.expand_path($PROGRAM_NAME)))
$LOAD_PATH.push(File.join(dir, 'bin'), File.join(dir, 'lib'))
$LOAD_PATH.delete(".")

ext = Encoding.default_external.name
err = nil
err = true unless ext == 'UTF-8'
err = true if ARGV.size > 4
ARGV.each{|v| err = true if v.size > 20}
abort if err

load 'mdconfig', wrap=true
require 'mdiary'
Mdiary::Main.new().start(ARGV)

