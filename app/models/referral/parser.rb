class Referral::Parser
  attr_accessor :options
  attr_accessor :report
  attr_accessor :error
  attr_accessor :message_format
  
  def has_error?
    @options[:error]
  end
  
  alias :"error?"  :"has_error?"
  
  def initialize options
    @options = options
  end
  
  def create_scanner text
    StringScanner.new text
  end
  
  def parse
    begin
      scan_messages
    rescue 
    end
    create_report
  end
  
  def create_report
    raise "Unable to parse. You need to define this method in sub class"
  end
  
  def message_format
    raise "Unable to parse. You need to define this method in sub class"
  end
  
  def scan_slip_code text  
    scanner = create_scanner(text)
    od_name =  scanner.scan(/^[a-zA-Z]+/i)
    analyse_od_name(od_name)
    
    book_number = scanner.scan(/^\d{3}/)
    analyse_book_number book_number
    
    code_number = scanner.scan(/^\d{3}$/)
    analyse_code_number(code_number)
    @options[:slip_code] = od_name + book_number + code_number   
  end
  
  def from_health_center?
    @options[:sender].place.class.to_s == "HealthCenter"
  end
  
  def from_od?
    @options[:sender].place.to_s == "OD"
  end
  
  def raise_error message
    @options[:error] = true
    @options[:error_message] = message
    raise message.to_s
  end
  
  def scan_phone_number text
    
    if(text == "" || text =="0")
        @options[:phone_number] = text
        return text
    end
    
    scanner = create_scanner(text)
    phone_number =  scanner.scan(/^\d{9,10}$/)
    if phone_number.nil?
      raise_error :referral_invalid_phone_number
    else  
      @options[:phone_number] = phone_number
    end
    phone_number
  end
  
  def scan_od text
    scanner = create_scanner(text)
    od_name =  scanner.scan(/^[a-zA-Z]+$/i)
    analyse_od_name(od_name)
  end
 
  def analyse_od_name od_name
    if od_name.nil?
      raise_error :referral_invalid_od 
    else
        begin
          if(@options[:sender].place.od.abbr.downcase() != od_name.downcase())
            raise_error :referral_invalid_not_in_od
          end
        rescue
           raise_error :referral_invalid_not_in_od
        end
        
        @options[:od_name] = od_name 
    end
   end
  
  def scan_book_number text
    scanner = create_scanner(text)
    book_number = scanner.scan(/^\d{3}$/)
    analyse_book_number book_number
  end
  
  def analyse_book_number book_number
    if book_number.nil?
      raise_error :referral_invalid_book_number
    else
      @options[:book_number] = book_number
    end
  end
  
  def scan_code_number text
    scanner = create_scanner(text)
    code_number = scanner.scan(/^\d{3}/)
    analyse_code_number(code_number)
  end
  
  def analyse_code_number code_number
    if(code_number.nil?)
      raise_error :referral_invalid_code_number
    else
      @options[:code_number] = code_number
    end
  end
  
  def scan_health_center text
    if(!text.empty?)
      scanner = create_scanner(text)
      health_center_code = scanner.scan(/^\d{6}/)
      if health_center_code.nil?
        raise_error :referral_invalid_health_center_format
      else
        hc = HealthCenter.find_by_code health_center_code
        if hc.nil?
          raise_error :referral_invalid_health_center_code
        else
          @options[:health_center_code] = health_center_code
          @options[:send_to_health_center] = hc
        end   
      end
    else
      @options[:health_center_code] = nil
    end
    @options[:health_center_code]
  end
  
  
  def scan_dynamic_format text, validator_name
     if Referral::Field::FixFieldClinic.include? validator_name
       scan_text_by_validator_name text, validator_name
     else
       field = Referral::Field.find_by_name validator_name
       raise_error "referral_invalid_validator" if field.nil?
       field.constraints.each do|constraint|
         validator = constraint.validator
         valid = validator.validate(text, validator_name)   
         if !valid
           raise_error validator_name
         else
           @options[validator_name.downcase.to_sym] = text
           @options[field.meaning_report_column.to_sym] = field.meaning
         end
       end
     end
  end
  
  def scan_text_by_validator_name text, validator_name
    self.send("scan_#{validator_name}", text)
  end
  
  def scan_messages    
    formats = message_format.format.split(Referral::MessageFormat::Separator)
    texts   = Referral::Parser.split_term( @options[:text], Referral::MessageFormat::Separator)
           
    formats.each_with_index do |format, index|
      validator_name = Referral::MessageFormat.raw_format(format)
      text = texts[index]
      
      raise_error :referral_field_mismatch_format if text.nil?
      scan_dynamic_format text.strip, validator_name
    end
    raise_error :referral_field_mismatch_format if formats.size != texts.size
  end
  
  def self.split_term(text, separator)
    result = []
    content = ""
    text.each_char do |c|
      if(c == separator )
         result << content 
         content = ""
      else
         content = content + c
      end
    end
    if text[text.size-1] == separator
      result << "" 
    else
      result << content
    end
    result
  end
  
end
