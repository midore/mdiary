module Mdiary

  class CheckStart

    def initialize(arg)
      @err = false
      ext = Encoding.default_external.name
      @err = true unless ext == 'UTF-8'
      m, @h = '', Hash.new
      arg.each{|x| (m = /^-(.*)/.match(x)) if /^-/.match(x); @h[m[1].to_sym] = x if m}
    end

    def base
      return help if (@h.has_key?(:h) or @h.has_key?(:help))
      check_arg
      return [@err, @h]
    end

    private
    def help
      arg_keys.each{|k,v| print "#{k}: #{v}\n"}
      return 'help'
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
      err_no_str = "No option"
      err_over_str = "Over words"
      err_time_str = "example: -at|-t \'2010/01/01/ 11:00"
      @h.keys.each{|k| return @err = err_no_str unless arg_keys["-#{k}"]}
      @h.each{|k,v|
        if k == :l then (return @err = err_over_str) if v.size > 3
        elsif k == :d then (return @err = err_over_str) if v.size > 10
        else; (return @err = err_over_str) if v.size > 30
        end
      }
      if @h.has_key?(:d)
        @err = arg_keys['-d'] if @h[:d].size < 5
        @err = arg_keys['-d'] unless /^\d{4}\-\d{2}$/.match(@h[:d])
      elsif (@h.has_key?(:at) or @h.has_key?(:t))
        (@h[:at].nil?) ? str = @h[:t] : str = @h[:at]
        return @err = err_time_str unless /\d{4}.\d{2}.\d{2}/.match(str)
        begin pt = Time.parse(str); rescue; return @err = 'err_time_str'; end
        (@h[:at].nil?) ? @h[:t]=pt : @h[:at]=pt
      end
      @h[:today] = Time.now if @h.has_key?(:today)
      @h[:a] = nil if @h[:a] == '-a'
    end

  end

end

