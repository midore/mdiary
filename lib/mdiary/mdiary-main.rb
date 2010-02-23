module Mdiary
 
  #---------------------- Main

  class Main

    include Setting
    def start(arg_h)
      return nil unless check_conf
      command(arg_h)
    end

    private
    def command(h)
      set_nowdir(h) # define @now_dir, @t
      return nil unless @now_dir
      x = h.keys[0]
      return run_add(h[:a]) if x == :a or x == :at
      return err_req unless exist?(@now_dir)
      (x == :d) ? x = h.keys[1] : x = h.keys[0]
      case x
      when :l then run_view(h[:l])
      when :s then run_search(h[:s], nil)
      when :st then run_search(h[:st], 'st')
      when :today then run_today
      end
    end

    def err_req
      print "No files in current month directory. Please, '-a' option.\n" unless exist?(@now_dir)
    end

    def exist?(dir)
      File.exist?(dir)
    end

    def run_request(a)
      return nil if a.empty?
      a.each_with_index{|x,y| print y + 1; x.to_s}
      Request.new(a, @trash_dir).base
    end

    def run_view(n)
      num = n.to_i if /\d/.match(n)
      num ||= default_n
      a = View.new(num, @now_dir).base
      run_request(a) if a
    end

    def run_search(w, st)
      return nil unless w
      a = Search.new(w, @now_dir, st).base
      run_request(a) if a
    end

    def run_today
      w = Time.now.strftime("%Y/%m/%d")
      run_search(w, nil)
    end

    def run_add(title)
      return nil if exist?(@now_dir) and max?
      make_dir(@now_dir) unless exist?(@now_dir)
      title ||= default_title
      Add.new(title, @t).base(@now_dir)
    end

    def i_t(t)
      return @t = Time.now if t.nil?
      return @t = t
    end

    def i_dir(t)
      i_t(t)
      @now_dir = File.join(@text_dir, @t.strftime("%Y-%m")) if @t
    end

    def i_xdir(str)
      d = File.join(@text_dir, str)
      return nil unless exist?(d)
      return @now_dir = d
    end

    def set_nowdir(h)
      return i_xdir(h[:d]) unless h[:d].nil?
      if h.has_key?(:t)
        i_dir(h[:t])
      elsif h.has_key?(:at)
        i_dir(h[:at])
      else
        i_dir(nil)
      end
    end

    def make_dir(path)
      # Add
      begin
        Dir.mkdir(path)
        print "maked directory: #{path}\n"
      rescue
        print "Error: make directory.\"#{path}\"\n"
        return false
      end
      return true if exist?(path)
    end

    def max?
      # Add
      return nil unless exist?(@now_dir)
      max = default_file_count if defined? default_file_count
      max = 90 unless max
      p s = Dir.entries(@now_dir).select{|x| /\.txt$/.match(x)}.size
      return false if s < max
      print "too many files. Edit bin/mdconfig.\n"
      return true
    end

  end

  #---------------------- Add

  class Add

    include Writer

    def initialize(title=nil, t)
      @title = title
      @t = t
    end

    def base(d)
      @now_dir = d
      make_diary
    end

    private
    def set_path
      f = File.join(@now_dir, @t.strftime("%Y-%m-%dT%H-%M-%S.txt"))
      return print "Same name file is exist.\n" if File.exist?(f)
      return f
    end

    def make_diary
      return nil unless path = set_path
      text = Diary.new(@title, @t).draft
      @t, @now_dir, @title = nil, nil, nil
      sleep 1
      writer(path, text)
      Request.new().text_open(path)
    end

  end

  #---------------------- View

  class View

    include Reader

    def initialize(num=nil, dir)
      @num = num
      @dir = dir
      @ary = Array.new
    end

    def base
      return print "Error: default_n\n" if @num < 1
      set_i_ary(@dir)
    end

    private
    def set_i_ary(d)
      Find.find(d){|x| 
        break if @ary.size == @num
        next unless File.extname(x) == '.txt'
        diary = get_diary(x)
        @ary << diary if diary
      }
      return @ary
    end

    def get_diary(x)
      begin
        h = view_h(x)
        to_obj(h) unless h.empty?
      rescue
        return nil
      end
    end

    def to_obj(h)
      t = Time.parse(h[:date])
      Diary.new(nil, t).load_up(h)
    end

  end

  #---------------------- Search

  class Search < View

    def initialize(word, dir, st=nil)
      @w = word
      @dir = dir
      @ary = Array.new
      @st = st if st == 'st'
    end

    def base
      return nil unless set_i_w
      @plus = 'plus' if @word == /\+/i
      return nil if @st && @plus
      set_i_ary(@dir)
    end

    private
    def set_i_w
      return @word = /\+/i if @w == '+'
      return print "Error: word > 2\n" if @w.size < 3
      begin
        @word = Regexp.new(@w, true)
      rescue RegexpError
        @word = nil
      end
    end

    def get_diary(x)
      begin
        h = find_index(x) unless @st
        h = find_content(x) unless @st.nil?
        to_obj(h) unless h.nil?
      rescue
        return nil
      end
    end
 
  end

  #--------------------- Request

  class Request

    def initialize(ary=nil, trash=nil)
      @ary = ary
      @num = ary.size if ary
      @trash = trash
    end

    def base
      @diary = @ary[0] if @num == 1
      unless @diary
        n = select_no
        @diary = @ary[n-1] if n
      end
      return clean_ary if @diary.nil?
      req = select_req
      run_req(req) 
    end

    def text_open(path)
      return false unless File.exist?(path)
      exec "vim #{path}"
    end

    private
    def run_req(req)
      @ary, @num = nil, nil
      case req
      when false then return nil
      when 'i' then @diary.detail
      when 'r' then text_remove(@diary.path)
      when 'e' then text_open(@diary.path)
      end
    end

    def text_remove(path)
      return nil unless File.exist?(path)
      new = File.join(@trash, File.basename(path))
      begin
        File.rename(path, new)
        print "Removed: #{new}\n"
      rescue
        return print "Error: trash directory\n"
      end
    end

    def select_no
      Select.new.base("Select NO", @num) 
    end

    def select_req
      str = "Select [i/e/r]"
      Select.new.base(str, false)
    end

    def clean_ary
      @ary, @num = nil, nil
    end

  end

  #---------------------------- Diary

  class Diary

    def initialize(title=nil, t=nil)
      @created = t
      @control = 'yes'
      @title = title
      @path = nil
      @category = 'diary'
    end

    attr_reader :path

    def load_up(h)
      h.each{|k,v| set_ins("@#{k}".to_sym, v)}
      return self
    end

    def to_s
      ary = [posted?, created_s, @title, @category]
      printf "\t[%s]\s[%-16s]\s[%s]\s(%s)\n" % ary
    end

    def detail
      ins_to_a{|x| print "#{x.to_s}: #{get_ins(x).to_s}\n"}
    end

    def draft
      @date = created_s 
      a = [:@date, :@control, :@category, :@title, :@content]
      to_txt(a)
    end

    def to_txt(a)
      str = String.new.encode("UTF-8")
      a.each{|i|
        m = i.to_s.match(/@(.*)/)
        str << "--#{m[1]}\n#{get_ins(i).to_s}\n" if m
      }
      return str
    end

    private
    def created_s
      @created.strftime("%Y/%m/%d %a %p %H:%M:%S")
    end

    def posted?
      @control == "yes" ? "-" : "+"
    end

    def set_ins(i, v)
      return nil unless i_defined?(i)
      self.instance_variable_set(i, v)
    end

    def get_ins(i)
      self.instance_variable_get(i)
    end

    def i_defined?(i) 
      self.instance_variable_defined?(i)
    end

    def ins_to_a
      self.instance_variables.each{|x|
        next unless get_ins(x)
        yield(x)
      }
    end

  end
 

  #---------------------------- Select

  class Select

    def base(str, opt)
      sec, ans = 7, ''
      begin
        timeout(sec){ans = receive_gets(str, opt)}
      rescue RuntimeError
        return print "Timeout. #{sec}sec...bye\n"
      rescue SignalException
        return print "\n"
      end
      return ans
    end

    private
    def receive_gets(str, opt)
      return false unless $stdin.tty?
      print "#{str}:\n"
      ans = $stdin.gets.chomp
      return false if /^n$|^no$/.match(ans)
      return false if ans.empty?
      case opt
      when true   # yes or no
        m = /^y$|^yes$/.match(ans)
        return false unless m
        return true
      when false  # return alphabet
        return false if /\d/.match(ans)
        return false if ans.size > 7
        return ans
      else        # return number
        i_ans = ans.to_i
        return false if i_ans > opt
        return false if ans =~ /\D/
        return false unless ans
        return i_ans
      end
    end

  end

  # end of module
end
