class User < ActiveRecord::Base
  Roles = ["national", "admin"]
  
  belongs_to :place
  
  validates_inclusion_of :role, :in => Roles, :allow_nil => true
  
  validates_uniqueness_of :user_name, :allow_nil => true
  
  validates_uniqueness_of :email, :allow_nil => true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => true

  validates_confirmation_of :password
  
  validates_uniqueness_of :phone_number, :allow_nil => true
  validates_presence_of :phone_number, 
                        :unless => Proc.new {|user| user.phone_number.nil? && !user.user_name.blank? && !user.password.blank?},
                        :message => "Phone can't be blank, unless you provide a username, a password and an email"
  validates_format_of :phone_number, :with => /^\d+$/, :unless => Proc.new {|user| user.phone_number.nil?}, :message => "Only numbers allowed"

  before_save :encrypt_password
  
  # Delegate country, province, etc., to place
  Place::Types.each { |type| delegate type.tableize.singularize, :to => :place }


  def self.authenticate email, pwd
    user = User.find_by_email email
    return nil if user.nil?
    return user if user.has_password? pwd
  end

  def write_places_csv source_file
    File.open(places_csv_file_name,"w+b") do |file|
      file.write(source_file.read)
    end
  end
  
  def places_csv_file_name
    Rails.root.join("public","placescsv", "#{id}.csv")
  end

  def has_password? submitted_pwd
    self.encrypted_password = encrypt submitted_pwd
  end

  def remember_me!
    self.remember_token = encrypt "#{salt}--#{id}"
    save false
  end

  def alert_numbers
    national_users = User.find_all_by_role "national"

    recipients = []

    recipients.concat User.phone_numbers health_center.users unless place.health_center?
    recipients.concat User.phone_numbers od.users
    recipients.concat User.phone_numbers province.users
    recipients.concat User.phone_numbers national_users
  end

  def can_report?
    place_id && (place.village? || place.health_center?)
  end

  def report_parser
    place.report_parser self
  end

  #data ={:user_name=>[],:password => [] ,...}
  def self.save_bulk data
    data[:user_name].each_with_index do |user_name, i|
      
      attrib = {
         :user_name => user_name,
         :email => data[:email][i],
         :password => data[:password][i],
         :password_confirmation => data[:password][i],
         :place_id => data[:place_id][i],
         :phone_number => data[:phone_number][i]
      }

      user = User.new attrib
      user.save
    end
  end

  def self.paginate_user page
    page = page.nil? ? 1 : page.to_i
    User.paginate :page => page, :per_page => 10
  end

  private
  
  def encrypt_password
    unless password.nil?
      self.salt = make_salt
      self.encrypted_password = encrypt password
    end
  end

  def encrypt pwd
    secure_hash "#{salt}#{pwd}"
  end

  def make_salt
    secure_hash "#{Time.now.utc}#{password}"
  end

  def secure_hash string
    Digest::SHA2.hexdigest string
    string
  end

  def self.phone_numbers users
    users.map { |u| u.phone_number }.reject { |n| n.nil? }
  end
end
