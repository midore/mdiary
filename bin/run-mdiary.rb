# coding: utf-8
#
#------------------------------------------
# run-mdiary.rb
#------------------------------------------

(print "Error: Only Ruby 1.9\n"; exit) if RUBY_VERSION < "1.9"
(print "Error: LANG"; exit) unless Encoding.default_external.name == 'UTF-8'

module Mdiary
  class Start
    def initialize
      conf_path = '/path/to/mdiary-conf'
      (print "Error: not found mdiary-conf\n"; exit) unless File.exist?(conf_path)
      load(conf_path)
    end
    def run
      require 'mdiary'
      err, arg_h = CheckStart.new(ARGV).base
      exit if err == 'help'
      (print "#{err}\n"; exit) if err
      Main.new(arg_h)
    end
  end
end

Mdiary::Start.new.run

