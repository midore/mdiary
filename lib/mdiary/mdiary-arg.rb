module Mdiary

  class CheckStart

    def initialize(arg)
      @arg = arg
      @err = nil
      @h = Hash.new
    end

    def base
      check_lang
      return @err = 'err0' unless @arg[0]
      check_arg
    end
    attr_reader :err, :h

    private
    def check_lang
      @err = 'lang' unless Encoding.default_external.name == 'UTF-8'
    end

    def help
      arg_keys.each{|k,v| print "#{k}: #{v}\n"}
    end

    def arg_keys
      a = {
        '-a'=>'add new file with specify title.',
        '-t'=>'example: -a \'NewTitle\' -t \'2010/01/01/ 11:00\'',
        '-at'=>'add new file without title. example: -at \'2010/01/01/ 11:00\'', 
        '-d'=>'specified directory. example: 2010-01',
        '-l'=>'print list.',
        '-today'=>'print today list',
        '-s'=>'search in title or category, control, date',
        '-st'=>'search in content',
        '-h | -help'=>'this help',
      }
    end

    def check_arg
      x, a, y, b = @arg
      return @err = 'err1' if x.size > 6
      return help if x =~ /^-h$|^-help$/
      k1, k2 = arg_key(x), arg_key(y)
      # if not match arg_keys
      return @err = 'err2' if k1.nil?
      @h[k1], @h[k2] = a, b
      @h[:today] = Time.now if @h.has_key?(:today)
      @err = 'Error: err3' if size_v(:a, 20)
      @err = 'Error: err4' if size_v(:t, 20)
      @err = 'Error: err5' if size_v(:at, 20)
      @err = 'Error: err6' if size_v(:d, 7)
      @err = 'Error: err7' if size_v(:l, 2)
      @err = 'Error: err8' if size_v(:s, 20)
      @err = 'Error: err9' if size_v(:st, 20)
    end

    def size_v(k, s)
      return nil unless @h[k]
      return true if @h[k].size > s
    end

    def arg_key(x)
      return nil unless arg_keys.has_key?(x)
      m = /\-(.*)/.match(x) if x =~ /^\-/
      return  m[1].to_sym if m
    end

  end

end

