module Mdiary

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
        k = i.to_s.gsub("@","--")
        str << "#{k}\n#{get_ins(i).to_s}\n"
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
 
  #---------------------- Main

  class Main

    include $MDIARYCONF

    def initialize
      @start = check_conf
    end

    def start(arg)
      return error_conf unless @start
      command(arg)
    end

    def text_open(path)
      return false unless exist?(path)
      clean_ins
      exec "vim #{path}"
    end

    def text_remove(path)
      return nil unless exist?(path)
       new = File.join(trash_dir, File.basename(path))
      begin
        File.rename(path, new)
        print "Saved: #{new}\n"
      rescue
        print "Error: trash directory\n"
      end
    end

    private
    def command(arg)
      x, a, b, c = arg
      case x
      when '-a'
        tit = default_title unless a
        tit = a if a
        Add.new(tit, nil).base unless b
        Add.new(tit, c).base if b == '-t'
      when '-at'
        Add.new(default_title, a).base if a
      when '-l'
        ChoiceDir.new().base_view(a)
      when '-d'
        ChoiceDir.new(a).base_view(c) if b == '-l'
        request_search(a, b ,c) if b =~ /^\-s$|^\-st$/
      when /^\-s$|^\-st$/
        request_search(nil, x, a)
      when '-today'
        w = Time.now.strftime("%Y/%m/%d")
        ChoiceDir.new().base_search(w)
      end
    end

    def request_search(d, st, w)
      ChoiceDir.new(d).base_search(w, st)
    end

    def exist?(dir)
      File.exist?(dir)
    end

    def check_conf
      return false unless exist?(data_dir)
      a, b = true, true
      a = make_dir(trash_dir) unless exist?(trash_dir)
      b = make_dir(text_dir) unless exist?(text_dir)
      return true if a and b
    end

    def error_conf
      print "Error: Directory.\n=> Need edit config file.(bin/mdconfig)\n"
    end

    def nowdir
      File.join(text_dir, @t.strftime("%Y-%m"))
    end

    def make_dir(path)
      begin
        Dir.mkdir(path)
        print "maked directory: #{path}\n"
      rescue
        print "Error: make directory \"#{path}\"\n"
        return false
      end
      return true
    end

    def clean_ins
      @dir, @now_dir = nil, nil
      print "...bye.\n"
      sleep 1
    end

  end

  #---------------------- Add

  class Add < Main

    include Writer

    def initialize(title=nil, t)
      @title = title
      set_i_t(t)
      set_i_nowdir
    end

    def base
      return nil unless check
      make_diary
    end

    def get_path
      return nil unless check
      set_path
    end

    private
    def check
      return nil unless @t
      return nil unless @now_dir
      return true
    end

    def make_diary
      path = set_path
      text = Diary.new(@title, @t).draft
      writer(path, text)
      text_open(path)
    end 

    def set_i_t(t)
      return @t = Time.now unless t
      begin
        pt = Time.parse(t)
      rescue
        return false
      end
      @t = pt
    end

    def set_i_nowdir
      return false unless @t
      d = nowdir
      return false unless make_dir(d) unless exist?(d)
      @now_dir = d
    end

    def set_path
      f = File.join(@now_dir, @t.strftime("%Y-%m-%dT%H-%M-%S.txt"))
      return f unless exist?(f)
    end

  end

  #---------------------- ChoiceDir

  class ChoiceDir < Main

    def initialize(d=nil)
      @dir= d
      set_i_dir
    end

    def base_view(n)
      set_i_num(n)
      View.new(@num, @now_dir).base if @now_dir
      View.new(@num, @now_dir_a).base_a if @now_dir_a
    end

    def base_search(w, st=nil)
      set_i_w(w)
      return nil unless @word
      Search.new(@word, @now_dir, st).base if @now_dir
    end
 
    private
    def set_i_num(n)
      @num = default_n unless n
      @num = n.to_i if n 
    end

    def set_i_w(w)
      w = '\+' if w == '+'
      begin
        @word = Regexp.new(w, true)
      rescue
      end
    end

    def set_i_dir
      err_str = "none of file in current month. \n"
      case @dir
      when nil
        # nowdir ( methods of Main class ) need to @t. 
        @t = Time.now
        return print err_str unless exist?(nowdir)
        @now_dir = nowdir
      when /^\d{4}-\d{2}$/
        d = File.join(text_dir, @dir)
        @now_dir = d if exist?(d)
      when /^2\d{3}$/
        @now_dir_a = get_dir
      end
    end

    def get_dir
      a = []
      Find.find(text_dir){|x|
        next unless File.directory?(x)
        next unless File.basename(x).include?(@dir)
        a << x
      }
      return a unless a.empty?
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
      return nil unless @num > 0
      set_i_ary(@dir)
      view
    end

    def base_a
      @dir.each{|d| set_i_ary(d)} 
      view
    end

    private
    def set_i_ary(d)
      @num = 20 unless @num
      Find.find(d){|x| 
        break if @ary.size == @num
        next unless File.extname(x) == '.txt'
        diary = get_diary(x)
        @ary << diary if diary
      }
    end

    def get_diary(x)
      h = view_h(x)
      h[:path] = x
      to_obj(h) unless h.empty?
    end

    def to_obj(h)
      title = h[:title]
      t = Time.parse(h[:date])
      Diary.new(title, t).load_up(h)
    end

    def view
      return nil if @ary.empty?
      @ary.each_with_index{|x,y| print y + 1; x.to_s}
      Request.new(@ary).base 
    end

  end

  #---------------------- Search

  class Search < View

    def initialize(word, dir, st=nil)
      @word = word
      @dir = dir
      @ary = Array.new
      @st = st if st == '-st'
    end

    def base
      @plus = 'plus' if @word == /\+/i
      return nil unless @st.nil? || @plus.nil?
      set_i_ary(@dir)
      view
    end

    private
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

    def initialize(ary)
      @ary = ary
      @num = ary.size
    end

    def base
      @diary = @ary[0] if @ary.size == 1
      unless @diary
        n = select_no
        @diary = @ary[n-1] if n
      end
      return clean_ary if @diary.nil?
      @req = select_req
      run_req 
    end

    private
    def run_req
      clean_ary
      case @req
      when false then return nil
      when 'i' then @diary.detail
      when 'r' then Main.new().text_remove(@diary.path)
      when 'e' then Main.new().text_open(@diary.path)
      end
    end

    def select_xreq
      str = 'Select [doc/post/up/del/n]'
      Select.new.base(str, false)
    end

    def select_no
      Select.new.base("Select NO", @num) 
    end

    def select_req
      str = "Select [i/e/r]"
      Select.new.base(str, false)
    end

    def clean_ary
      self.instance_variables.each{|i|
        next if i == :@req
        next if i == :@diary
        self.instance_variable_set(i, nil)
      }
    end

  end

  #---------------------------- RequestSelect

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
      ans = $stdin.gets.chop
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

