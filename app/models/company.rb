class Company < ActiveRecord::Base


  #Associations
  belongs_to :user
  has_many :brands, :dependent => :destroy
  has_many :brand_user_groups, :dependent => :destroy
  has_many :company_privacies, :dependent => :destroy
  has_one :default_brand, :class_name => "Brand", :conditions => ["is_default = true"]
  has_many :brand_admins, :class_name => "BrandUserGroup", :conditions => ["brand_user_groups.brand_id is null OR brand_user_groups.access_type = #{BrandUserGroup::ACCESS_TYPES["Brand Admin"]}"]
  has_many :brand_admin_users, :source => :user, :through => :brand_admins
  has_many :brand_managers, :class_name => "BrandUserGroup", :conditions => ["brand_user_groups.access_type = #{BrandUserGroup::ACCESS_TYPES["Brand Manager"]}"]
  has_many :brand_manager_users, :source => :user, :through => :brand_managers
  belongs_to :membership
  has_many :streams, :dependent => :destroy
  has_many :favourite_streams, :class_name => "FavouriteStream", :through => :streams
  has_many :payments
  has_many :followers, :class_name => "CompanyFollower"
  has_many :brand_services
  has_many :active_services, :class_name => "BrandService", :conditions => ["brand_services.secret is not null and brand_services.token is not null"]

  #Call Backs
  after_create :create_depedencies

  #Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :url, :with => /^(#{URI::regexp(%w(http https))})$/
  validate :validate_name

  def validate_name
    unless self.name.blank?
      user = User.find_by_user_name(self.name)
      unless user.nil?
        self.errors.add(:name, "#{I18n.translate(:has_been_taken)}" )
      end
    end
  end

  def profile_image
    Asset.find_by_attachable_id_and_attachable_type(self.id, "Company")
  end

  def create_depedencies
    self.update_attributes(:cycle_start_date => Time.now, :next_payment_date => Time.now + 1.month)
    self.brands.create(:name => self.name,:is_default => true,:active => true, :active_skin_id => Skin::edintity_default.id)
    BrandUserGroup.create(:company_id => self.id, :user_id => self.user_id, :access_type => BrandUserGroup::BrandAdmin)
  end

  def is_allowed_to_create_brand?
    return true if self.membership.membership_type == "business" && self.membership.brand_count.to_i == 0 # This is for unlimited membership
    (self.brands.count.to_i - 1) < self.membership.brand_count.to_i && self.membership.membership_type == "business"
  end

  def is_allowed_to_add_user_group?
    return true if self.membership.membership_type == "business" && self.membership.user_count.to_i == 0 # This is for unlimited membership
    self.brand_user_groups.count.to_i < self.membership.user_count.to_i && self.membership.membership_type == "business"
  end

  def is_brand_admin?(current_user)
    self.brand_admin_users.collect(&:id).include?(current_user.id)
  end

  def get_company_brands_data(start_date, end_date)
    brands = []
    data = {}
    brand_followers_hash = {}
    self.brands.each do |brand|
      brand_followers = 0
      data[brand.display_name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[brand.display_name].nil?
      follwers = brand.followers.find(:all, :select => "Date(created_at) AS date,COUNT(*) as count", :conditions => ["created_at >= ? and created_at <= ?", start_date, end_date], :group => "date")
      follwers.each do |follower|
        data[brand.display_name][DateTime.parse(follower.date).to_i*1000] = [] if data[brand.display_name][DateTime.parse(follower.date).to_i*1000].blank?
        data[brand.display_name][DateTime.parse(follower.date).to_i*1000] << 1
        brand_followers += 1
      end
      brands << "#{brand.display_name} (#{brand_followers})"
      brand_followers_hash[brand.display_name] = brand_followers
    end
    brands.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys.collect{|key| key + "(#{brand_followers_hash[key]})"}, Brand.flatten(data.values)]
  end

  def get_locations_data(start_date, end_date)
    data = {}
    followers = self.followers.find(:all, :joins => [:user], :select => "users.country as country,Date(company_followers.created_at) AS date,COUNT(company_followers.id) as count", :conditions => ["company_followers.created_at >= ? and company_followers.created_at <= ?", start_date, end_date], :group => "country, date")
    followers.each do |follower|
      data[follower.country] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[follower.country].nil?
      data[follower.country][DateTime.parse(follower.date).to_i*1000] = [] if data[follower.country][DateTime.parse(follower.date).to_i*1000].blank?
      data[follower.country][DateTime.parse(follower.date).to_i*1000] << 1
    end
    data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values)]
  end  

  def get_top_streams(start_date, end_date, filter, limit)
    data = []
    if filter == "edintity"
      streams = self.streams.find(:all, :include => [:comments, :favourite_streams], :conditions => ["streams.service_id is null and streams.created_at >= ? and streams.created_at <= ?", start_date, end_date])
    elsif filter == "all"
      streams = self.streams.find(:all, :include => [:comments, :favourite_streams], :conditions => ["streams.created_at >= ? and streams.created_at <= ?", start_date, end_date])
    else
      streams = self.streams.find(:all, :include => [:comments, :favourite_streams], :conditions => ["streams.service_id = ? and streams.created_at >= ? and streams.created_at <= ?", filter, start_date, end_date])
    end
    streams.each do |stream|
      comments = stream.comments.count
      favorites = stream.favourite_streams.count
      total = comments + favorites + stream.view_count
      data << [stream, total]
    end
    data = data.sort {|x,y| y[1] <=> x[1] }
    data = data[0..limit-1]
    data.collect {|x| x[0]}
  end
  
  def self.get_upgrade_stats(start_date, end_date, table_view = false)
    unless table_view
      data = {}
      small = Membership.find_by_id(3)
      mid = Membership.find_by_id(4)
      enterprise = Membership.find_by_id(5)
      data["#{small.name} to #{mid.name}"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      data["#{small.name} to #{enterprise.name}"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      data["#{mid.name} to #{enterprise.name}"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      data["#{mid.name} to #{small.name}"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      data["#{enterprise.name} to #{mid.name}"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      data["#{enterprise.name} to #{small.name}"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      upgrades = UserUpgrade.find(:all, :select => "Date(created_at) AS date, from_membership_id, to_membership_id", :conditions => ["created_at >= ? and created_at <= ? and from_to is not null and from_to != '1-2'", start_date, end_date])
      upgrades.each do |upgrade|
        data["#{upgrade.from_membership.name} to #{upgrade.to_membership.name}"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
        data["#{upgrade.from_membership.name} to #{upgrade.to_membership.name}"][DateTime.parse(upgrade.date).to_i*1000] = [] if data["#{upgrade.from_membership.name} to #{upgrade.to_membership.name}"][DateTime.parse(upgrade.date).to_i*1000].blank?
        data["#{upgrade.from_membership.name} to #{upgrade.to_membership.name}"][DateTime.parse(upgrade.date).to_i*1000] << 1
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values, true)]
    else
      upgrades = UserUpgrade.find(:all, :select => "Date(created_at) AS date, count(from_to) as from_to_count, from_to", :conditions => ["created_at >= ? and created_at <= ? and from_to is not null and from_to != '1-2'", start_date, end_date], :group => "date, from_to")
    end
  end

  def is_brand_manager?(current_user)
    self.brand_manager_users.collect(&:id).include?(current_user.id)
  end

  def current_cycle_followers
    self.followers.count(:conditions => { "company_followers.created_at" => self.cycle_start_date..(self.cycle_start_date + 1.month)})
  end

  def has_twitter_service
    self.brand_services.twitter_authorized.length > 0
  end


  def has_flickr_service
    self.brand_services.flickr_authorized.length > 0
  end

  def has_facebook_service
    self.brand_services.facebook_authorized.length > 0
  end

  def has_vimeo_service
    self.brand_services.vimeo_authorized.length > 0
  end

  def has_youtube_service
    self.brand_services.youtube_authorized.length > 0
  end

  def has_tumblr_service
    self.brand_services.tumblr_authorized.length > 0
  end

  def has_delicious_service
    self.brand_services.delicious_authorized.length > 0
  end

  def has_stumbleupon_service
    self.brand_services.stumbleupon_authorized.length > 0
  end

  def read_or_create_stream_actions
    if self.default_brand.default_stream_action.blank?
      DefaultStreamAction.create(:brand_id => self.default_brand.id)
    else
      self.default_brand.default_stream_action
    end
  end

  def favourites
    Stream.find_all_by_id(self.favourite_streams.collect(&:stream_id))
  end

  def self.get_stats(membership_id  = nil)
    unless membership_id.blank?
      Company.count(:all, :conditions => ["active = 1 and membership_id in (?)", membership_id])
    else
      Company.count(:all, :conditions => ["active = 1 and membership_id in (3,4,5,6)"])
    end
  end


end
