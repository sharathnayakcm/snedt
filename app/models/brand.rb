class Brand < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  belongs_to :company
  has_many :streams
  has_many :favourite_streams, :class_name => "FavouriteStream", :through => :streams
  has_many :brand_services, :dependent => :destroy
  has_many :brand_user_groups, :dependent => :destroy
  has_one :brand_privacy, :dependent => :destroy
  has_many :active_services, :class_name => "BrandService", :conditions => ["brand_services.secret is not null and brand_services.token is not null"]
  has_many :pending_services, :class_name => "BrandService", :conditions => ["brand_services.secret is null and brand_services.token is null"]
  has_one :default_stream_action
  has_many :subbrands, :class_name => "Brand", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Brand", :foreign_key => "parent_id"
  has_many :followers, :class_name => "CompanyFollower"
  has_many :post_service_groups
  has_many :posts
  has_one :brand_privacy
  has_many :skins
  has_many :brand_managers, :class_name => "BrandUserGroup", :conditions => ["brand_user_groups.access_type = #{BrandUserGroup::ACCESS_TYPES["Brand Manager"]}"]
  has_many :brand_manager_users, :source => :user, :through => :brand_managers
  has_many :content_managers, :class_name => "BrandUserGroup", :conditions => ["brand_user_groups.access_type = #{BrandUserGroup::ACCESS_TYPES["Content Manager"]}"]
  has_many :content_manager_users, :source => :user, :through => :content_managers
  # validations
  validates_presence_of :name
  validates_format_of :brand_url, :with => /^(#{URI::regexp(%w(http https))})$/, :allow_blank => true

  # scopes
  named_scope :active_brands, :conditions => "is_default = false and active = true "
  named_scope :inactive_brands, :conditions => "is_default = false and active = false"
  named_scope :sub_brands, lambda { |brand_id| {:conditions => {:parent_id => brand_id} } }
  named_scope :company_brands, lambda { |company_id| {:conditions => {:company_id => company_id, :is_default => false} } }
  named_scope :link_sharing_services, :conditions => "service_id = 1 or service_id = 2 or service_id = 9"
  named_scope :default_active_brand, :conditions => "is_default = true and active = true "
  #Call Backs
  after_create :create_brand_dependents

  acts_as_url :name

  def to_param
    url # or whatever you set :url_attribute to
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

  def has_facebook_page
    self.brand_services.facebook_page_authorized.length > 0
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

  def post_groups(service_type)
    post_groups = self.post_service_groups.find(:all, :include => [:post_type], :conditions => ["post_types.name = ?", service_type.capitalize])
    post_groups
    
  end

  def create_brand_dependents
    BrandPrivacy.create(:brand_id => self.id, :company_id => self.company_id, :visible_to => BrandPrivacy::PRIVACY_TYPES["Everyone"], :profile => BrandPrivacy::PRIVACY_TYPES["Everyone"], :rss => BrandPrivacy::PRIVACY_TYPES["Everyone"], :stream => BrandPrivacy::PRIVACY_TYPES["Everyone"])
  end

  def read_or_create_brand_privacy_setting(company_id)
    if self.brand_privacy.blank?
      BrandPrivacy.create(:brand_id => self.id, :company_id => company_id, :visible_to => 1)
    else
      self.brand_privacy
    end
  end

  def read_or_create_stream_actions
    if self.default_stream_action.blank?
      DefaultStreamAction.create(:brand_id => self.id)
    else
      self.default_stream_action
    end
  end

  #TODO : Incomplete Code
  def get_followers
    followers_list = []
    self.followers.collect{|follower| followers_list << follower.following_user}
    followers_list = followers_list -  self.friends
  end

  def create_affiliation(invitee, access_type_id)
    brand_user_group = self.brand_user_groups.find(:all, :conditions => ["user_id = ? ", invitee.id])
    if brand_user_group.blank?
      brand_user_group = self.brand_user_groups.create(:company_id => self.company_id, :user_id => invitee.id, :access_type => access_type_id, :status => false)
      brand_user_group.update_attribute(:brand_id, nil) if access_type_id.to_i == BrandUserGroup::ACCESS_TYPES["Brand Admin"].to_i
      return true
    else
      return false
    end
  end


  def confirm_affliation_request(current_user)
    brand_user_group = self.brand_user_groups.find(:first, :conditions => ["user_id = ?", current_user.id])
    unless brand_user_group.blank?
      brand_user_group.update_attribute(:status, true)
      return true
    else
      return false
    end
  end



  def allowed_to_view?(current_user, privacy_attribute)
    return true if self.brand_privacy.read_attribute(privacy_attribute).to_s == "1"
    comp =  self.company
    return true if comp.user == current_user
    if (comp.brand_user_groups.map{|f| f.user_id}).include?(current_user.id)
      brand_user_group = comp.brand_user_groups.find_by_user_id(current_user.id)
      return true if brand_user_group.access_type <= self.brand_privacy.read_attribute(privacy_attribute)
    end     
  end

  def has_access?(current_user)
    !(self.brand_user_groups.find(:first, :conditions => ["user_id = ?", current_user.id])).blank?
  end

  def delete_brands
    Brand.destroy_all("parent_id = #{self.id}")
    self.destroy
  end

  def profile_image
    Asset.find_by_attachable_id_and_attachable_type(self.id, "Brand")
  end

  def active_skin
    self.skins.find_by_id(self.active_skin_id, :include => [ {:skin_styles => [:panel_type, :style_attribute]} ])
  end

  def read_or_create_active_skin(skin_id = nil)
    if skin_id.blank?
      skin = self.active_skin
    else
      skin = Skin.find_by_id(skin_id)
    end
    if skin.blank?
      skin = Skin.create(:brand_id => self.id, :name => "My Skin - s1")
      self.update_attribute(:active_skin_id, skin.id)
    end
    skin
  end

  def create_skin(name)
    Skin.create(:brand_id => self.id, :name => name)
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

  def self.get_services_data(start_date, end_date, graph_for, for_id)
    data = {}
    total_followers = 0
    stream_comments = Comment.find(:all, :select => "comments.user_id as follower_id, Date(comments.created_at) as date, streams.service_id, streams.id, services.name as service_name", :joins => "INNER JOIN streams ON streams.id = comments.stream_id LEFT OUTER JOIN services ON streams.service_id = services.id", :conditions => ["comments.created_at >= ? and comments.created_at <= ? and #{graph_for == 'brand' ? 'streams.brand_id' : 'streams.company_id'} = ?", start_date, end_date, for_id])
    stream_favorites = FavouriteStream.find(:all, :select => "favourite_streams.user_id as follower_id, Date(favourite_streams.created_at) as date, streams.service_id, streams.id, services.name as service_name", :joins => "INNER JOIN streams ON streams.id = favourite_streams.stream_id LEFT OUTER JOIN services ON streams.service_id = services.id", :conditions => ["favourite_streams.created_at >= ? and favourite_streams.created_at <= ? and #{graph_for == 'brand' ? 'streams.brand_id' : 'streams.company_id'} = ?", start_date, end_date, for_id])
    stream_views = StreamView.find(:all, :select => "stream_views.user_id as follower_id, Date(stream_views.created_at) as date, streams.service_id, streams.id, services.name as service_name", :joins => "INNER JOIN streams ON streams.id = stream_views.stream_id LEFT OUTER JOIN services ON streams.service_id = services.id", :conditions => ["stream_views.created_at >= ? and stream_views.created_at <= ? and #{graph_for == 'brand' ? 'streams.brand_id' : 'streams.company_id'} = ?", start_date, end_date, for_id])
    stream_followers = stream_favorites + stream_comments + stream_views
    added_followers = []
    stream_followers.each do |follower|
      unless added_followers.include?([follower.follower_id, follower.date, follower.service_name])
        added_followers << [follower.follower_id, follower.date, follower.service_name]
        service = follower.service_name || "edintity"
        data[service] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[service].nil?
        data[service][DateTime.parse(follower.date).to_i*1000] = [] if data[service][DateTime.parse(follower.date).to_i*1000].blank?
        data[service][DateTime.parse(follower.date).to_i*1000] << 1
        total_followers += 1
      end
    end
    data.blank? ? [total_followers, [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]]] : [total_followers, [data.keys, flatten(data.values)]]
  end

  def self.flatten(hash_array, float_value = false)
    flattened_array = []
    hash_array.each do |hash|
      array = []
      hash.each do |k,v|
        if float_value
          array << [k, v.collect{|i| i.to_f}.sum]
        else
          array << [k, v.collect{|i| i.to_i}.sum]
        end
      end
      flattened_array << array
    end
    flattened_array
  end

  def display_brand_url
    self.brand_url.blank? ? self.company.url : self.brand_url
  end


  def display_name
    truncate(name, :length => 23)
  end

  def is_brand_manager?(current_user)
    self.brand_manager_users.collect(&:id).include?(current_user.id)
  end

  def is_content_manager?(current_user)
    self.content_manager_users.collect(&:id).include?(current_user.id)
  end

  def favourites
    Stream.find_all_by_id(self.favourite_streams.collect(&:stream_id))
  end
end
