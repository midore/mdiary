#!/path/to/ruby191
# coding: utf-8
#
#------------------------------------------
# mdiary-run.rb
# ruby 1.9.1p376 
# 
# 2010-06-02
# ruby 1.9.2dev (2010-05-31 revision 28117) [x86_64-darwin10.3.0]
#
# last: 2010-07-01
#------------------------------------------

(print "Error: Only Ruby 1.9\n"; exit) if RUBY_VERSION < "1.9"
(print "Error: LANG"; exit) unless Encoding.default_external.name == 'UTF-8'

module Mdiary
  class Start
    def run
      conf = File.join(ENV['HOME'], '.m_diary', 'mdiary_conf')
      (print "Error: not found mdiary_conf\n"; exit) unless File.exist?(conf)
      load conf, wrap=true
      require 'mdiary'
      # check arg
      err, arg_h = CheckStart.new(ARGV).base
      exit if err == 'help'
      (print "#{err}\n"; exit) if err
      Main.new().start(arg_h)
    end
  end
end

Mdiary::Start.new.run

