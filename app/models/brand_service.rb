class BrandService < ActiveRecord::Base

  # Associations
  belongs_to :service
  belongs_to :user
  belongs_to :brand
  belongs_to :company

  # Named Scopes
  named_scope :twitter_unauthorized, :conditions => "service_id = 1 and (token is null or secret is null)"
  named_scope :twitter_authorized, :conditions => "service_id = 1 and token is not null and secret is not null"
  named_scope :flickr_authorized, :conditions => "(service_id = 1 or service_id = 2 or service_id = 7 or service_id = 9) and token is not null and secret is not null"
  named_scope :link_sharing_services, :conditions => "service_id = 1 or service_id = 2 or service_id = 9 or service_id = 10"
  named_scope :blog_sharing_services, :conditions => "service_id = 1 or service_id = 2 or service_id = 9 or service_id = 10"
  named_scope :photo_sharing_services, :conditions => "service_id = 1 or service_id = 2 or service_id = 7 or service_id = 9 or service_id = 10"
  named_scope :video_sharing_services, :conditions => "service_id = 3 or service_id = 4 or service_id = 1 or service_id = 2 or service_id = 9"
  named_scope :video_authorized, :conditions => "(service_id = 3 or service_id = 4 or service_id = 1 or service_id = 2 or service_id = 9) and token is not null and secret is not null"
  named_scope :facebook_authorized, :conditions => "service_id = 2 and token is not null and secret is not null"
  named_scope :facebook_page_authorized, :conditions => "service_id = 10 and token is not null and secret is not null and fb_page_id is not null and fb_page_id != ''"
  named_scope :vimeo_authorized, :conditions => "service_id = 4 and token is not null and secret is not null"
  named_scope :youtube_authorized, :conditions => "service_id = 3 and token is not null and secret is not null"
  named_scope :tumblr_authorized, :conditions => "service_id = 9 and token is not null and secret is not null"
  named_scope :delicious_authorized, :conditions => "service_id = 5 and token is not null and secret is not null"
  named_scope :stumbleupon_authorized, :conditions => "service_id = 6 and token is not null and secret is not null"
  named_scope :facebook_services, :conditions => "service_id = 2"
  named_scope :facebook_page_services, :conditions => "service_id = 10"
  named_scope :youtube_services, :conditions => "service_id = 3"
  named_scope :vimeo_services, :conditions => "service_id = 4"
  named_scope :flickr_services, :conditions => "service_id = 7"
  named_scope :tumblr_services, :conditions => "service_id = 9"
  named_scope :my_services, :conditions => "token is not null and secret is not null"

  #Validations
  validates_uniqueness_of :token, :scope => [:service_id, :brand_id], :message => "The account you are trying to connect already exists. Please login with the different account.", :if => Proc.new { |u| u.service_id != 10 }

  #Instant Methods
  def has_twitter_oauth?
    self.service_id == 1 and self.token and self.secret
  end

  def has_oauth?
    self.user_name and self.token and self.secret
  end

  def create_or_update_twitter_account_with_oauth_token(token, secret, user_name, profile_name)
    self.update_attributes(:token => token, :secret => secret, :user_name => user_name, :profile_name => profile_name)
  end

  def create_or_update_flickr_account_with_oauth_token(auth_token)
    self.update_attributes(:token => auth_token.token, :secret => "Flickr", :profile_name => auth_token.user['username'], :user_name => auth_token.user['nsid'])
  end

  def create_or_update_tumblr_account_with_oauth_token(params, name)
    self.update_attributes(:token => params["oauth_token"], :secret => params["oauth_verifier"], :profile_name => name, :user_name => name)
  end

  def create_or_update_vimeo_account_with_oauth_token(auth_token, user_name, profile_name)
    self.update_attributes(:token => auth_token.token, :secret => auth_token.secret, :user_name => user_name, :profile_name => profile_name)
  end

  def create_or_update_youtube_account_with_oauth_token(auth_token, user_name)
    self.update_attributes(:token => auth_token, :secret => "Youtube", :user_name => user_name, :profile_name => user_name)
  end

  def has_facebook_oauth?
    self.service_id == 2 and self.token
  end

  def has_facebook_page_oauth?
    self.service_id == 10 and self.token
  end

  def has_vimeo_oauth?
    self.service_id == 4 and self.token
  end

  def has_youtube_oauth?
    self.service_id == 3 and self.token
  end

  def has_tumblr_oauth?
    self.service_id == 9 and self.token
  end

  def has_delicious_oauth?
    self.service_id == 5 and self.token
  end

  def has_stumbleupon_oauth?
    self.service_id == 6 and self.token
  end

  def create_or_update_facebook_account_with_oauth_token(access_token, client)
    self.update_attributes(:token => access_token.token, :secret => "Facebook", :profile_name => client.me.info['name'], :user_name => client.me.info['name'])
  end

  def display_name
    if ['Vimeo', "Flickr"].include?(self.service.name)
      [self.profile_name, self.user_name].join('-')
    else
      if self.service_id == 10
        fb_page_name = self.fb_page_name.blank? ? "Not configured" : self.fb_page_name
        [self.user_name, fb_page_name].join("-")
      else
        self.user_name
      end
    end
  end

  def self.get_service_stats(start_date, end_date, table_view = false)
    unless table_view
      data = {}
      Service.all.each do |service|
        data[service.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      end
      brand_services = self.my_services.find(:all, :joins => [:company], :select => "Date(brand_services.created_at) AS date, service_id", :conditions => ["brand_services.created_at >= ? and brand_services.created_at <= ? and companies.membership_id in (3,4,5)", start_date, end_date])
      brand_services.each do |brand_service|
        data[brand_service.service.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[brand_service.service.name].nil?
        data[brand_service.service.name][DateTime.parse(brand_service.date).to_i*1000] = [] if data[brand_service.service.name][DateTime.parse(brand_service.date).to_i*1000].blank?
        data[brand_service.service.name][DateTime.parse(brand_service.date).to_i*1000] << 1
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values)]
    else
      brand_services = self.my_services.find(:all, :joins => [:company, :service], :select => "Date(brand_services.created_at) AS date, count(service_id) as service_count, services.name as service_name", :conditions => ["brand_services.created_at >= ? and brand_services.created_at <= ? and companies.membership_id in (3,4,5)", start_date, end_date], :group => "date, brand_services.service_id")
    end
  end

  def self.count_by_service_id(service_id = nil)
    unless service_id.blank?
      self.count(:all, :conditions => ["service_id = ? AND secret is not null AND token is not null", service_id])
    else
      self.count(:all, :conditions => ["secret is not null AND token is not null"])
    end
  end

end
