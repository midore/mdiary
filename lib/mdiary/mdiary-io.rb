module Mdiary

  module Writer

    def writer(path, data)
      File.open(path, 'w:utf-8'){|f| f.print data}
      print "Saved: #{path}\n"
    end

  end

  module Reader

    def reader(path)
      return nil unless FileTest.exist?(path)
      IO.readlines(path)
    end

    def reader_v(path)
      return nil unless FileTest.exist?(path)
      arr = []
      f = File.open(path)
      f.each_line{|line| 
        break if line =~ /^--content\n$/
        arr << line.chop
      }
      f.close
      arr
    end

    def text_to_h(path)
      ary = reader_v(path)
      to_h(ary) if ary
    end

    def to_h(ary)
      return nil unless ary
      h, k = Hash.new, ""
      ary.each_with_index{|x,y|
        k = x.gsub("--",'').strip.to_sym if x =~ /^--/
        h[k] = x.strip unless x =~ /^--/
      }
      return h
    end

    def find_v(path)
      h = to_h(reader_v(path))
      unless @plus
        return h if @word.match(h.values.to_s)
      else
        return nil if h[:control].nil?
        return h if not h[:control] == "yes"
      end
    end
 
    def find_t(path)
      m = open(path){|f| f.grep(@word)}
      to_h(reader_v(path)) unless m.empty?
    end
 
  end

  # end of moudle
end
