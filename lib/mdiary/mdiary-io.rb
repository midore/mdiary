module Mdiary

  module Setting

    include $MDIARYCONF

    def check_conf
      (print "Error: Not found #{scpt_path}\n"; exit) unless File.exist?(scpt_path)
      days = File.join(data_dir, 'text')
      trash = File.join(data_dir, 'trash')
      errmsg(days) unless check_dir(days)
      errmsg(trash) unless check_dir(trash)
      @text_dir, @trash_dir = days, trash
      return true
    end

    def check_dir(d)
      e = []
      e << File.exist?(d)
      e << File.directory?(d)
      e << File.readable?(d)
      e << File.writable?(d)
      e << File.executable?(d)
      return true unless e.include?(false)
    end

    def errmsg(d=nil)
      begin
        Dir.mkdir(d)
        print "maked directory #{d}\n"
      end
    end

  end

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
      return ary_to_h(a, path)
    end

    def find_index(path)
      h = view_h(path)
      unless @plus
        m = h.values.select{|v| v.match(@word)}
        return h unless m.empty?
      else
        return h unless h[:control] == 'yes'
      end
    end

    def find_content(path)
      i, m = nil, nil
      a, mark = [], /^--content$/
      IO.foreach(path){|line|
        if line.match(mark)
          i = true; next
        end
        (i.nil?) ? a.push(line) : m = line.match(@word)
        break if m
      }
      return ary_to_h(a, path) if m
    end

    def ary_to_h(ary, path)
      h, k = Hash.new, nil
      ary.each{|x|
        hit = x.match(/--(.*)\n$/)
        k = hit[1].to_sym if hit
        h[k] = x.strip unless hit
      }
      h[:path] = path
      return h
    end
 
  end

  # end of moudle
end
