module Mdiary

  class CheckStart

    def initialize(arg)
      @err = false
      k, @h = nil, Hash.new
      arg.each{|x| m = /^-(.*)/.match(x); (m) ? (k = m[1].to_sym; @h[k] = nil) : @h[k] ||= x}
    end

    def base
      return "Error: $LANG must be UTF-8" unless Encoding.default_external.name == 'UTF-8'
      return help if (@h.has_key?(:h) or @h.has_key?(:help))
      return check_arg
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
      return @err if check_arg_size
      return @err if check_opt
      check_d if @h.has_key?(:d)
      check_l if @h.has_key?(:l)
      check_at_t if (@h.has_key?(:at) or @h.has_key?(:t))
      @h[:today] = Time.now if @h.has_key?(:today)
      return [@err, @h]
    end

    def check_arg_size
      err_over_str = "Erro: Over characters"
      @h.each{|k,v|
        next unless v
        if k == :l then (return @err = err_over_str) if v.size > 3
        elsif k == :d then (return @err = err_over_str) if v.size > 10
        else; (return @err = err_over_str) if v.size > 30
        end
      }
      return nil
    end

    def check_opt
      err_no_str = "Error: No option"
      @h.keys.each{|k| return @err = err_no_str unless arg_keys["-#{k}"]}
      return nil
    end

    def check_d
      return @err = arg_keys['-d'] if (@h[:d].nil? or @h[:d].size < 5)
      @err = arg_keys['-d'] unless /^\d{4}\-\d{2}$/.match(@h[:d])
    end

    def check_at_t
      err_str = "Erro: Date. example: -at|-t \'2010/01/01/ 11:00"
      return @err = err_str if @h.has_key?(:at) and @h.has_key?(:t)
      (@h[:at].nil?) ? str = @h[:t] : str = @h[:at]
      return @err = err_str unless /\d{4}.\d{2}.\d{2}/.match(str)
      begin pt = Time.parse(str); rescue; return @err = err_str; end
      (@h[:at].nil?) ? @h[:t]=pt : @h[:at]=pt
    end

    def check_l
      err_num_str = "Error: Not Integer"
      return nil if @h[:l].nil?
      return @err = err_num_str if /\D/.match(@h[:l])
      return @err = "Error: zero" if @h[:l] == "0"
      @h[:l] = @h[:l].to_i
    end

  end

end

