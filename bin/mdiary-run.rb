# coding: utf-8

#------------------------------------------
# mdiary-run.rb
# ruby 1.9.1p376 
# 2010-01-04
#------------------------------------------

def check_arg(arg)
  err = nil
  # ENV['LANG']
  ext = Encoding.default_external.name
  return err = 'lang' unless ext == 'UTF-8'
  # ARGV.size
  return err = 'err0' unless arg[0]
  arg.each_with_index{|x,no|
    y = no%2
    err = 'err1' if y == 0 and x.size > 6
    err = 'err2' if y == 1 and x.size > 20
  }
  return err
end

dir = File.dirname(File.dirname(File.expand_path($PROGRAM_NAME)))
bin = File.join(dir, 'bin')
lib = File.join(dir, 'lib')
$LOAD_PATH.push(bin, lib)
$LOAD_PATH.delete(".")

arg = ARGV
arg.delete("")
err = check_arg(arg)
exit unless err.nil?

conf = File.join(bin, 'mdconfig')
exit unless File.exist?(conf)

load conf, wrap=true
require 'mdiary'
Mdiary::Main.new().start(arg)

