module Mdiary

  module Writer

    def writer(path, data)
      File.open(path, 'w:utf-8'){|f| f.print data}
      print "Saved: #{path}\n"
    end

  end

  module Reader

    def reader(path)
      return nil unless File.exist?(path)
      IO.readlines(path)
    end

    def view_h(path)
      a, mark = [], /^--content$/
      IO.foreach(path){|line|
        break if line.match(mark)
        a.push(line) 
      }
      return ary_to_h(a)
    end

    def search_plus(path)
      h = view_h(path)
      return h unless h[:control] == 'yes'
    end

    def search_h(path)
      return find_index(path) unless @st
      return find_content(path)
    end

    def find_index(path)
      h = view_h(path)
      m = h.values.select{|v| v.match(@word)}
      return h unless m.empty?
    end

    def find_content(path)
      a, mark = [], /^--content$/
      i, m = nil, false
      IO.foreach(path){|line|
        i = true if line.match(mark)
        m = true if line.match(@word)
        a.push(line) unless i
        break if i and m
      }
      return ary_to_h(a) if m
    end

    def ary_to_h(ary)
      h, k = Hash.new, nil
      ary.each{|x|
        hit = x.match(/--(.*)\n$/)
        k = hit[1].to_sym if hit
        h[k] = x.strip unless hit
      }
      return h
    end
 
  end

  # end of moudle
end
