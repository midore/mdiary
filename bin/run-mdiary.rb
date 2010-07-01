#!/path/to/ruby19
# coding: utf-8
#
#------------------------------------------
# run-mdiary.rb
#------------------------------------------

(print "Error: Only Ruby 1.9\n"; exit) if RUBY_VERSION < "1.9"
(print "Error: LANG"; exit) unless Encoding.default_external.name == 'UTF-8'

module Mdiary

  class Start

    def own_dir
      dir = File.dirname(File.dirname(File.expand_path($PROGRAM_NAME)))
      lib = File.join(dir, 'lib')
      $LOAD_PATH.push(lib)
      $LOAD_PATH.delete(".")
    end

    def run
      own_dir
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

    private :own_dir

  end

end

Mdiary::Start.new.run

