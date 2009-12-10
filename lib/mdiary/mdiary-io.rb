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

    def mark_content(ary)
      @mark = ary.find_index("--content\n") unless ary.empty?
    end

    def text_to_h(path)
      ary = reader(path)
      to_h(ary, path) if ary
    end

    def to_h(ary, path)
      return nil unless mark_content(ary)
      h, k = Hash.new, ""
      ary[0..@mark].each_with_index{|x,y|
        k = x.gsub("--",'').strip.to_sym if x =~ /^--/
        h[k] = x.strip unless x =~ /^--/
      }
      #h[:edited] = File.mtime(path)
      return h
    end

    def text_find_w(path, w)
      ary = reader(path)
      str = ary.select{|x| not x=~/^--/}.join()
      return to_h(ary, path) if w.match(str)
    end
  
  end

  # end of moudle
end
