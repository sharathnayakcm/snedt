class User < ActiveRecord::Base
  include UserHelper
  # has_many :services, :through => :user_services
  has_many :user_services
  has_many :brand_services
  has_many :active_services, :class_name => "UserService", :conditions => ["user_services.secret is not null and user_services.token is not null"]
  has_many :pending_services, :class_name => "UserService", :conditions => ["user_services.secret is null and user_services.token is null"]
  belongs_to :user_detail
  has_many :posts
  acts_as_authentic
  has_one :twitter_account, :dependent => :destroy
  has_many :streams
  has_many :user_tabs
  has_many :followers
  has_many :preferences
  has_many :rss_links
  has_many :admin_rss_links
  has_many :custom_tabs
  has_many :saved_searches
  has_many :privacy_groups
  has_many :post_service_groups
  has_many :followings, :class_name => "Follower", :foreign_key => "follower_id"
  has_many :blocked_users
  has_many :custom_stream_filters
  has_many :tags
  has_many :stream_tags, :through => :streams
  has_many :skins
  has_one :user_privacy_setting
  has_one :default_stream_action
  has_and_belongs_to_many :notifications
  has_many :favourite_streams
  belongs_to :membership
  has_many :payments
  has_one :company, :dependent => :destroy
  has_one :company_user_group, :dependent => :destroy
  has_many :brand_user_groups, :dependent => :destroy
  has_many :stream_views
  has_many :company_followers
  has_many :assets
  has_one :downgrade
  has_and_belongs_to_many :topics
  has_many :activities
  has_one :thank_you ,:through => :streams

  #VALIDATIONS
  validates_presence_of :email, :user_name, :full_name
  validates_uniqueness_of :user_name
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i , :if => Proc.new { |a| !a.email.blank? }
  validates_length_of :email, :maximum=>50
  validates_length_of :password, :minimum => 7, :allow_nil => false , :on => :create
#  validates_format_of :full_name, :with => /^([a-z][a-z ]*)$/i, :if => Proc.new { |a| !a.full_name.blank? }
  validates_format_of :user_name, :with => /^([a-z0-9]*)$/i, :message => "can only contain letters and numbers", :if => Proc.new { |a| !a.user_name.blank? }
  validates_length_of :user_name, :minimum => 4, :allow_nil => false
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/png','image/gif','image/jpg',], :only => :update
  validates_attachment_size :avatar, :in => 1..1048576, :only => :update
  named_scope :active, :conditions => "active = 1"
  named_scope :free_users, :conditions => "membership_id = 1"
  named_scope :premium_users, :conditions => "membership_id = 2"

  #CONSTANTS
  # Paperclip
#  ACCESS_KEY_ID = 'AKIAI2774245UYOVXRWA'
#  SECRET_ACCESS_KEY = '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'
#  BUCKET = 'edintitydemo'
  USER_TYPE_ID ={
    :followers => 2,
    :followings => 3,
    :friends => 4
  }

  PRIVACY_TYPES = {
    :every_one => 1,
    :followers => 2,
    :followings => 3,
    :friends => 4,
    :just_me => 5
  }

#  has_attached_file :avatar,
#    :storage => 's3',
#    :server => 'edintitydemo.s3.amazonaws.com',
#    :bucket => BUCKET,
#    :path => "uploads/:attachment/:id/:styles.:extension",
#    :s3_credentials => {
#    :access_key_id => ACCESS_KEY_ID,
#    :secret_access_key => SECRET_ACCESS_KEY },
#    :s3_permissions => 'public-read',
#    :styles => {
#    :thumb=> "100x100#",
#    :small => "150x150>" }, :only => :update


  #ACCESSORS
  attr_accessor :validates_length_of_password_field_options

  #NAMED SCOPES
  named_scope :active, :conditions => "active = '1'"
  named_scope :spammed_users, :condition => "is_spammed_user = true "

  after_create :read_or_create_stream_actions
  validate :validate_user_name
  before_save :generate_perishable_token

  def generate_perishable_token
    self.perishable_token = Digest::MD5.hexdigest("#{Time.now}-#{self.id}") if self.active || self.changed.include?("email")
  end

  acts_as_authentic do |config|
    config.disable_perishable_token_maintenance true
  end

  def create_privacy_settings(full_name_setting)
    UserPrivacySetting.create(:user_id => self.id, :profile => User::PRIVACY_TYPES[:every_one], :rss => User::PRIVACY_TYPES[:every_one], :stream => User::PRIVACY_TYPES[:every_one], :full_name => full_name_setting || User::PRIVACY_TYPES[:every_one], :is_searchable => true)
  end

  def validate_user_name
    unless self.user_name.blank?
      company = Company.find_by_name(self.user_name)
      unless company.nil?
        self.errors.add(:user_name, "#{I18n.translate(:has_been_taken)}" )
      end
      unless BLOCKED_USER_NAMES.index(self.user_name.downcase).blank?
        self.errors.add(:user_name, "#{I18n.translate(:user_name_not_allowed_1)}" )
        return
      end
      blocked_user_names = BLOCKED_USER_NAMES.join("-")
      user_name_length = self.user_name.length.to_i
      (4..user_name_length).each_with_index do |user_name_index, idx|
        unless blocked_user_names.index(user_name.downcase[0, user_name_index.to_i]).blank?
          self.errors.add(:user_name, "#{I18n.translate(:user_name_not_allowed_1)}" )
            return
        end
        unless blocked_user_names.index(user_name.downcase[idx, (idx == 0 ? 1 : idx)+3]).blank?
          self.errors.add(:user_name, "#{I18n.translate(:user_name_not_allowed_1)}" )
            return
        end
      end
    end
  end

  def active_skin
    self.skins.find_by_id(self.active_skin_id, :include => [ {:skin_styles => [:panel_type, :style_attribute]} ])
  end

  def get_full_name(current_user)
    follower_privacy_groups = current_user.blank? ? [User::PRIVACY_TYPES[:every_one].to_s] : current_user.member_of_privacy_groups_of(self)
    name = ""
    begin
      if (self.user_privacy_setting && (follower_privacy_groups.include?(self.user_privacy_setting.full_name.to_i.to_s) || self.user_privacy_setting.full_name.blank?)) || self.id == current_user.id || self.user_privacy_setting.blank?
        name = self.full_name
      else
        name = "Hidden"
      end
    rescue
      name = "Hidden"
    end
  end

  def display_full_name(current_user)
    name = get_full_name(current_user)
    "<a href='/profiles/#{self.user_name}'>#{name} \\ #{self.user_name}</a>"
  end

  def display_full_name_for_privacy(current_user)
    name = get_full_name(current_user)
    "#{name} / #{self.user_name}"
  end


  def read_or_create_active_skin(skin_id = nil)
    if skin_id.blank?
      skin = self.active_skin
    else
      skin = Skin.find_by_id(skin_id)
    end
    if skin.blank?
      skin = Skin.create(:user_id => self.id, :name => "My Skin - s1")
      self.update_attribute(:active_skin_id, skin.id)
    end
    skin
  end

  def create_skin(name)
    Skin.create(:user_id => self.id, :name => name)
  end

  def read_or_create_privacy_setting
    if self.user_privacy_setting.blank?
      UserPrivacySetting.create(:user_id => self.id, :profile => 1, :rss => 1, :stream => 1, :is_searchable => 1)
    else
      self.user_privacy_setting
    end
  end

  def read_or_create_stream_actions
    if self.default_stream_action.blank?
      DefaultStreamAction.create(:user_id => self.id)
    else
      self.default_stream_action
    end
  end

  def create_user_service_stream_actions
    self.active_services.all.each do |user_service|
      if user_service.default_stream_action.blank?
        DefaultStreamAction.create(:user_service_id => user_service.id)
      end
    end
  end

  def friends
    followings_ids =  []
    followers_ids = []
    self.followers.collect{|follower| followers_ids << follower.follower_id }
    self.followings.collect{|following| followings_ids << following.user_id }
    friends_ids = (followings_ids) & (followers_ids)
    User.find(:all, :conditions => ["id in (?)", friends_ids])
  end

  def get_followers
    followers_list = []
    self.followers.collect{|follower| followers_list << follower.following_user}
    followers_list = followers_list -  self.friends
  end

  def get_followings
    followings_list = []
    self.followings.collect{|following| followings_list << following.user}
    followings_list = followings_list -  self.friends
  end


  def self.search(keyword, current_user)
    keyword = "#{keyword}%" unless keyword.blank?
    u = User.find(:all, :joins => :user_privacy_setting, :conditions => ["active = true and (users.full_name like(?) or ( users.friends_find = 1 and users.email like (?) ) ) ", keyword, keyword])
  end

  def active_tabs
    user_tabs = []
    custom_tabs = []
    user_tabs = self.user_tabs.find(:all, :joins => [:tab], :select => "user_tabs.id as id, tabs.id as tab_id, tabs.name as tab_name, tabs.tab_path as tab_path")
    custom_tabs = self.custom_tabs.find(:all, :select => "custom_tabs.id as id, custom_tabs.id as tab_id, custom_tabs.name as tab_name, 'display_custom_streams' as tab_path")
    user_tabs.concat(custom_tabs)
  end

  def shared_services(service_type)
    # services = self.active_services.send("#{service_type.downcase}_sharing_services")
    user_service_ids = ""
    post_group_services = self.post_service_groups.find(:all, :include => [:post_type], :conditions => ["post_types.name = ?", service_type.capitalize])
    post_group_services.collect{|post_group_service| user_service_ids << post_group_service.user_service_ids unless user_service_ids.blank?}
    post_group_user_services = self.active_services.find(:all, :conditions => ["id in (?)", user_service_ids.split(',')]) unless user_service_ids.blank?
    post_group_user_services
    # services = services.concat(post_group_user_services) unless post_group_user_services.blank?
    # services
  end

  def post_groups(service_type)
    post_groups = self.post_service_groups.find(:all, :include => [:post_type], :conditions => ["post_types.name = ?", service_type.capitalize])
    post_groups
  end

  def member_of_privacy_groups_of(user)
    is_member_of = [User::PRIVACY_TYPES[:every_one].to_s]
    if user.get_followers.include?(self)
      is_member_of << User::PRIVACY_TYPES[:followers].to_s
    end
    if user.get_followings.include?(self)
      is_member_of << User::PRIVACY_TYPES[:followings].to_s
    end
    if user.friends.include?(self)
      is_member_of << User::PRIVACY_TYPES[:friends].to_s
    end
    #  groups = self.privacy_groups
    groups = user.privacy_groups
    groups.each do |group|
      if group.user_ids.to_s.split(",").include?(self.id.to_s)
        is_member_of << "PG-#{group.id}"
      elsif !(group.group_ids.to_s.split(",") & is_member_of).blank?
        is_member_of << "PG-#{group.id}"
      end
    end
    is_member_of
  end

  def get_privacy_groups(users, privacy_type_id)
    privacy_groups = []
    unless users.empty?
      groups = PrivacyGroup.find(:all, :conditions => "user_id in (#{users})")
      groups.each do |group|
        if group.group_ids.to_s.split(",").include?(privacy_type_id.to_s) || group.user_ids.split(",").include?(self.id.to_s)
          privacy_groups << "PG-#{group.id}"
        end
      end
    end

    return privacy_groups
  end

  def followers_streams
    followers_user_ids = self.get_followers.collect{|follower_user| follower_user.id }
    privacy_groups = self.get_privacy_groups(followers_user_ids, PRIVACY_TYPES[:followings])
    user_privacy_groups = [User::PRIVACY_TYPES[:every_one], User::PRIVACY_TYPES[:followings]]
    user_privacy_groups.concat(privacy_groups)
    unless followers_user_ids.blank?
      Stream.find(:all, :include => [:user, {:user_service => [:service]}], :conditions => [
          "(streams.user_id in (?)  AND
          (((users.privacy_type_id is null OR users.privacy_type_id in (#{User::PRIVACY_TYPES[:every_one]}, #{User::PRIVACY_TYPES[:followings]})) AND streams.user_service_id is null) OR user_services.privacy_type_id in (?)) AND
          streams.is_deleted is null ) ",
          followers_user_ids, user_privacy_groups], :order => "stream_created_at DESC")
    end
  end

  def followings_streams
    followings_user_ids = self.get_followings.collect{|following_user| following_user.id }
    privacy_groups = self.get_privacy_groups(followings_user_ids, PRIVACY_TYPES[:followers])
    user_privacy_groups = [User::PRIVACY_TYPES[:every_one], User::PRIVACY_TYPES[:followers]]
    user_privacy_groups.concat(privacy_groups)
    unless followings_user_ids.blank?
      Stream.find(:all, :include => [:user, {:user_service => [:service]}], :conditions => [
          "(streams.user_id in (?) AND
(((users.privacy_type_id is null OR users.privacy_type_id in (#{User::PRIVACY_TYPES[:every_one]}, #{User::PRIVACY_TYPES[:followings]})) AND streams.user_service_id is null) OR user_services.privacy_type_id in (?)) AND
streams.is_deleted is null )",
          followings_user_ids, user_privacy_groups], :order => "stream_created_at DESC")
    end
  end

  def friends_streams
    friends_user_ids = self.friends.collect{|friend_user| friend_user.id }
    privacy_groups = self.get_privacy_groups(friends_user_ids, PRIVACY_TYPES[:friends])
    user_privacy_groups = [User::PRIVACY_TYPES[:every_one], User::PRIVACY_TYPES[:friends]]
    user_privacy_groups.concat(privacy_groups)

    unless friends_user_ids.blank?
      Stream.find(:all, :include => [{:user => [:user_privacy_setting]}, {:user_service => [:service]}], :conditions => [
          "(streams.user_id in (?) AND (streams.report_abuse is null) AND (user_privacy_settings.stream in (1,4)) AND
(((users.privacy_type_id is null OR users.privacy_type_id in (#{User::PRIVACY_TYPES[:every_one]}, #{User::PRIVACY_TYPES[:friends]})) AND streams.user_service_id is null) OR user_services.privacy_type_id in (?)) AND
streams.is_deleted is null)",
          friends_user_ids, user_privacy_groups], :order => "stream_created_at DESC")
    end
  end

  def friends_edintity_streams
    friends_user_ids = self.friends.collect{|friend_user| friend_user.id }
    privacy_groups = self.get_privacy_groups(friends_user_ids, PRIVACY_TYPES[:friends])
    user_privacy_groups = [User::PRIVACY_TYPES[:every_one], User::PRIVACY_TYPES[:friends]]
    user_privacy_groups.concat(privacy_groups)
    unless friends_user_ids.blank?
      Stream.find(:all, :include => [{:user => [:user_privacy_setting]}, {:user_service => [:service]}], :conditions => [
          "(streams.user_id in (?) AND (streams.report_abuse is null) AND (user_privacy_settings.stream in (1,4)) AND
(((users.privacy_type_id is null OR users.privacy_type_id in (#{User::PRIVACY_TYPES[:every_one]}, #{User::PRIVACY_TYPES[:friends]})) AND streams.user_service_id is null)) AND
streams.is_deleted is null)",
          friends_user_ids], :order => "stream_created_at DESC")
    end
  end

  def followers_edintity_streams
    followers_user_ids = self.get_followers.collect{|follower_user| follower_user.id }
    privacy_groups = self.get_privacy_groups(followers_user_ids, PRIVACY_TYPES[:followings])
    user_privacy_groups = [User::PRIVACY_TYPES[:every_one], User::PRIVACY_TYPES[:followings]]
    user_privacy_groups.concat(privacy_groups)
    unless followers_user_ids.blank?
      Stream.find(:all, :include => [:user, {:user_service => [:service]}], :conditions => [
          "(streams.user_id in (?) AND (streams.report_abuse is null) AND
          (((users.privacy_type_id is null OR users.privacy_type_id in (#{User::PRIVACY_TYPES[:every_one]}, #{User::PRIVACY_TYPES[:followings]})) AND streams.user_service_id is null)) AND
          streams.is_deleted is null) ",
          followers_user_ids, user_privacy_groups], :order => "stream_created_at DESC")
    end
  end

  def followings_edintity_streams
    followings_user_ids = self.get_followings.collect{|following_user| following_user.id }
    privacy_groups = self.get_privacy_groups(followings_user_ids, PRIVACY_TYPES[:followings])
    user_privacy_groups = [User::PRIVACY_TYPES[:every_one], User::PRIVACY_TYPES[:followings]]
    user_privacy_groups.concat(privacy_groups)
    unless followings_user_ids.blank?
      Stream.find(:all, :include => [:user, {:user_service => [:service]}], :conditions => [
          "(streams.user_id in (?) AND
          (((users.privacy_type_id is null OR users.privacy_type_id in (#{User::PRIVACY_TYPES[:every_one]}, #{User::PRIVACY_TYPES[:followings]})) AND streams.user_service_id is null)) AND
          streams.is_deleted is null) ",
          followings_user_ids], :order => "stream_created_at DESC")
    end
  end

  def custom_streams(custom_tab)
    user_ids = []
    user_ids.concat(custom_tab.filter_user_ids.to_s.split(','))
    user_type_ids = custom_tab.user_type_ids.to_s.split(',')

    if user_type_ids.include?("#{User::USER_TYPE_ID[:friends]}")
      user_ids.concat(Follower.friends(self))
    end

    if user_type_ids.include?("#{User::USER_TYPE_ID[:followers]}")
      user_ids.concat(Follower.followings(self))
    end

    if user_type_ids.include?("#{User::USER_TYPE_ID[:followings]}")
      user_ids.concat(Follower.followers(self))
    end
    user_service_ids = custom_tab.service_ids.blank? ? "" : " and streams.service_id in (#{custom_tab.service_ids}) "
    Stream.find(:all, :include => [:user, {:user_service => [:service]}], :conditions => [
        "streams.user_id in (?) AND (streams.report_abuse is null) and
( ( ((users.privacy_type_id is null OR users.privacy_type_id in (?) OR (users.privacy_type_id = 1) ) AND streams.user_service_id is null) ) OR
(user_services.privacy_type_id in (?)
OR (user_services.privacy_type_id = 1 ))) #{user_service_ids}
AND streams.is_deleted is null",
        user_ids, custom_tab.user_type_ids, custom_tab.user_type_ids ])
  end

  def already_following_this_friend(friend)
    already_following = false
    self.followers.each do |follower|
      if follower.follower_id == friend
        already_following = true
      end
    end
    already_following
  end

  def already_following_user(user)
    already_following = false
    self.followings.each do |following|
      if following.user_id == user
        already_following = true
      end
    end
    already_following
  end

  def reported_as_spammer(user)
    SpammedUser.find_by_user_id_and_spammed_by_id_and_revealed_at(user.id, self.id, nil)
  end

  def marked_as_spammer
    spammed_user = SpammedUser.find(:all, :conditions => ["user_id = ? and is_spammer = ?", self.id, 1])
    !spammed_user.blank?
  end

  def is_favourite_stream(stream)
    is_favourite = self.favourite_streams.find_by_stream_id(stream.id)
    !is_favourite.blank?
  end

  def already_thanked(stream)
    thanked = ThankYou.find_by_stream_id_and_user_id(stream,self.id)
    thanked.present?
  end

  def favourites
    streams = []
    self.favourite_streams.each do |fav|
      streams << fav.stream if fav.stream.brand_id.blank?
    end
    streams
  end

  def is_blocked(blocking_user_id)
    BlockedUser.find_by_user_id_and_blocked_user_id(blocking_user_id, self.id)
  end
  def spammed_users
    self.find_all_by_is_spammed_user()
  end
  def has_twitter_service
    self.user_services.twitter_authorized.length > 0
  end

  def has_flickr_service
    self.user_services.flickr_authorized.length > 0
  end

  def has_facebook_service
    self.user_services.facebook_authorized.length > 0
  end

  def has_facebook_page
    self.user_services.facebook_page_authorized.length > 0
  end

  def has_vimeo_service
    self.user_services.vimeo_authorized.length > 0
  end

  def has_youtube_service
    self.user_services.youtube_authorized.length > 0
  end

  def has_tumblr_service
    self.user_services.tumblr_authorized.length > 0
  end

  def has_delicious_service
    self.user_services.delicious_authorized.length > 0
  end

  def has_stumbleupon_service
    self.user_services.stumbleupon_authorized.length > 0
  end

  def profile_image
    Asset.find_by_attachable_id_and_attachable_type(self.id, "User")
  end

  class << self
    def anonymous
      @anonymous ||= AnonymousUser.new
    end

    def current
      Thread.current[:user] || anonymous
    end

    def current=(user)
      # For some unknown reason, assigning Thread.current[:user] a User object
      # fetched through an association (or, we're hoping, through a session
      # cookie) and then attempting to reload the object triggers an infinite
      # loop through our access control system. Doing a vanilla find of the User
      # before assigning it to Thread.current[:user] fixes this in our test
      # environment, so we're hoping it fixes the infinite loops occurring in
      # our production environment, too.
      Thread.current[:user] = user.is_a?(User) ? User.find_without_access_control(user.id) : nil
    end
  end


  def activate!
    self.active = true
    save
  end

  def active?
    true
  end

  def is_active?
    self.active
  end

  def unused_tabs
    Tab.find_by_sql("select * from tabs t where t.id not in (select tab_id from user_tabs where user_id = #{self.id} and tab_id != '5') ")
  end

  def is_notifiable?(notification_type)
    return false if self.notifications.blank?
    self.notifications.collect(&:code).include?(notification_type)
  end

  def allowed_to_view?(current_user, privacy_attribute)
    return true if self == current_user
    follower_privacy_groups = current_user.blank? ? [User::PRIVACY_TYPES[:every_one].to_s] : current_user.member_of_privacy_groups_of(self)
    follower_privacy_groups.include?(self.user_privacy_setting.read_attribute(privacy_attribute).to_s)
  end

  def create_company(params, membership_id)
    begin
      Company.transaction do
        company = Company.new(:user_id => self.id, :name => params[:name], :url => params[:url], :membership_id => membership_id, :active => true)
        if company.save
          Brand.new(:name => company.name, :company_id => company.id, :is_default => true, :active => true).save
          CompanyPrivacy.new(:visible_to => CompanyPrivacy::Everyone, :company_id => company.id).save
          CompanyUserGroup.new(:user_id => self.id, :access_type => CompanyUserGroup::Admin, :company_id => company.id).save
        end
      end
    rescue
      return false
    end
  end

  def is_brand_admin?
    self.company.brand_admin_users.collect(&:id).include?(self.id)
  end

  def check_payment_status?
    if self.company
      company_membership = self.company.membership
      if company_membership.membership_type == "business" && company_membership.amount.to_i > 0
        check_payment = self.company.payments.find(:last)
        if !check_payment.nil? && check_payment.status.to_i != Payment::STATUS[:success]
          return false
        end
      end
      return true
    end
  end

  def self.get_overall_country_stats
    users = self.find(:all, :select => "country,COUNT(*) as count", :conditions => "country is not null and active = 1", :group => "country")
    overall_country_data = Array.new(users.length, 0)
    0.upto(users.length-1).each { |i|
      overall_country_data[i] = [users[i].country, users[i].count]
    }
    overall_country_data
  end

  def self.get_monthly_country_stats
    users = self.find(:all, :select => "country,YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "country is not null and YEAR(created_at) = YEAR(NOW()) and active = 1", :group => "mon, country")
    monthly_country_data = {}
    data = {}
    data_array = Array.new(12, 0)
    0.upto(users.length-1).each { |i|
      data[users[i].country] = data[users[i].country].to_a << [users[i].mon, users[i].count]
    }
    data.each {|key, value|
      value.each do |val|
        data_array[val[0].to_i - 1] = val[1] unless val.blank?
      end
      monthly_country_data[key] = data_array
      data_array = Array.new(12, 0)
    }
    monthly_country_data
  end

  def self.get_quarterly_country_stats
    users = User.find(:all, :select => "country,YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "country is not null and YEAR(created_at) = YEAR(NOW()) and active = 1", :group => "mon, country")
    quarterly_country_data = {}
    data = {}
    data_array = Array.new(12, 0)
    0.upto(users.length-1).each { |i|
      data[users[i].country] = data[users[i].country].to_a << [users[i].mon, users[i].count]
    }
    data.each {|key, value|
      value.each do |val|
        data_array[val[0].to_i - 1] = val[1] unless val.blank?
      end
      quarterly_data_array = Array.new(4,0)
      0.upto(3).each { |i| quarterly_data_array[i] = data_array[i*3].to_i + data_array[i*3 +1].to_i + data_array[i*3 +2].to_i }
      quarterly_country_data[key] = quarterly_data_array
      data_array = Array.new(12, 0)
      quarterly_data_array = Array.new(4,0)
    }
    quarterly_country_data
  end

  def self.get_weekly_country_stats
    users = User.find(:all, :select => "country,YEAR(created_at) AS yr,WEEK(created_at) AS mon,COUNT(*) as count", :conditions => "country is not null and YEAR(created_at) = YEAR(NOW()) and active = 1", :group => "mon, country")
    weekly_country_data = {}
    data = {}
    data_array = Array.new(DateTime.now().cweek.to_i,0)
    0.upto(users.length-1).each { |i|
      data[users[i].country] = data[users[i].country].to_a << [users[i].mon, users[i].count]
    }
    data.each {|key, value|
      value.each do |val|
        data_array[val[0].to_i - 1] = val[1] unless val.blank?
      end
      weekly_country_data[key] = data_array
      data_array = Array.new(DateTime.now().cweek.to_i,0)
    }
    weekly_country_data
  end

  def self.get_free_user_signup_stats(start_date, end_date, table_view = false)
    free_data = [[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date).to_i*1000, 0]]
    free = User.find(:all, :select => "Date(created_at) AS date,COUNT(*) as count", :conditions => ["created_at >= ? and created_at <= ? and membership_id = 1 and active = 1", start_date, end_date], :group => "date")
    free.each do |f|
      free_data << [DateTime.parse(f.date).to_i*1000, f.count]
    end
    free_data
  end

  def self.get_premium_user_signup_stats(start_date, end_date, table_view = false)
    premium_data = [[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date).to_i*1000, 0]]
    premium = User.find(:all, :select => "Date(created_at) AS date,COUNT(*) as count", :conditions => ["created_at >= ? and created_at <= ? and membership_id = 2 and active = 1", start_date, end_date], :group => "date")
    premium.each do |f|
      premium_data << [DateTime.parse(f.date).to_i*1000, f.count]
    end
    premium_data
  end

  def self.get_individual_user_signup_stats(start_date, end_date, table_view=false)
    unless table_view
      data = {}
      Membership.individual.each do |membership|
        data[membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      end
      individual = User.find(:all, :joins => [:membership], :select => "Date(users.created_at) AS date, membership_id", :conditions => ["users.created_at >= ? and users.created_at <= ? and users.active = 1 and memberships.membership_type = 'individual'", start_date, end_date])

      individual.each do |indv|
        data[indv.membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[indv.membership.name].nil?
        data[indv.membership.name][DateTime.parse(indv.date).to_i*1000] = [] if data[indv.membership.name][DateTime.parse(indv.date).to_i*1000].blank?
        data[indv.membership.name][DateTime.parse(indv.date).to_i*1000] << 1
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values)]
    else
      individual = User.find(:all, :joins => [:membership], :select => "Date(users.created_at) AS date, memberships.name as membership_name, count(users.id) as user_count", :conditions => ["users.created_at >= ? and users.created_at <= ? and users.active = 1 and memberships.membership_type = 'individual'", start_date, end_date], :group => "date, users.membership_id")
    end
  end

  def self.get_company_signup_stats(start_date, end_date, table_view = false)
    unless table_view
      data = {}
      Membership.business.each do |membership|
        data[membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      end
      companies = Company.find(:all, :joins => [:membership], :select => "Date(companies.created_at) AS date, membership_id", :conditions => ["companies.created_at >= ? and companies.created_at <= ? and memberships.membership_type = 'business'", start_date, end_date])
      companies.each do |company|
        data[company.membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[company.membership.name].nil?
        data[company.membership.name][DateTime.parse(company.date).to_i*1000] = [] if data[company.membership.name][DateTime.parse(company.date).to_i*1000].blank?
        data[company.membership.name][DateTime.parse(company.date).to_i*1000] << 1
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values)]
    else
      companies = Company.find(:all, :joins => [:membership], :select => "Date(companies.created_at) AS date, memberships.name as membership_name, count(companies.id) as company_count", :conditions => ["companies.created_at >= ? and companies.created_at <= ? and memberships.membership_type = 'business'", start_date, end_date], :group => "date, companies.membership_id")
    end
  end

  def self.get_country_signup_stats(start_date, end_date, table_view = false)
    unless table_view
      data = {}
      users = User.find(:all, :select => "Date(users.created_at) AS date, country", :conditions => ["users.created_at >= ? and users.created_at <= ? and users.active = 1", start_date, end_date])
      users.each do |user|
        unless user.country.blank?
          data[user.country] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[user.country].nil?
          data[user.country][DateTime.parse(user.date).to_i*1000] = [] if data[user.country][DateTime.parse(user.date).to_i*1000].blank?
          data[user.country][DateTime.parse(user.date).to_i*1000] << 1
        end
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values)]
    else
      User.find(:all,  :select => "Date(users.created_at) AS date, country, count(users.id) as users_count", :conditions => ["users.created_at >= ? and users.created_at <= ? AND users.country is not null", start_date, end_date], :group => "users.created_at, country")
    end
  end

  def self.get_upgrade_stats(start_date, end_date, table_view = false)
    unless table_view
      data = {}
      free = Membership.find_by_id(1)
      premium = Membership.find_by_id(2)
      data["#{free.name} to #{premium.name}"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      upgrades = UserUpgrade.find(:all, :select => "Date(created_at) AS date", :conditions => ["created_at >= ? and created_at <= ? and from_to = '1-2'", start_date, end_date])
      upgrades.each do |upgrade|
        data["#{free.name} to #{premium.name}"][DateTime.parse(upgrade.date).to_i*1000] = [] if data["#{free.name} to #{premium.name}"][DateTime.parse(upgrade.date).to_i*1000].blank?
        data["#{free.name} to #{premium.name}"][DateTime.parse(upgrade.date).to_i*1000] << 1
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values)]
    else
      upgrades = UserUpgrade.find(:all, :select => "Date(created_at) AS date, count(from_to) as from_to_count", :conditions => ["created_at >= ? and created_at <= ? and from_to = '1-2'", start_date, end_date], :group => "date, from_to")
    end
  end

  def self.get_free_user_monthly_signup_stats
    monthly_free_data = Array.new(12,0)
    free = User.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and membership_id = 1 and active = 1", :group => "yr, mon")
    free.each do |f|
      monthly_free_data[f.mon.to_i - 1] = f.count
    end
    monthly_free_data
  end

  def self.get_premium_user_monthly_signup_stats
    monthly_premium_data = Array.new(12,0)
    premium = User.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and membership_id = 2 and active = 1", :group => "yr, mon")
    premium.each do |p|
      monthly_premium_data[p.mon.to_i - 1] = p.count
    end
    monthly_premium_data
  end

  def self.get_individual_user_monthly_signup_stats
    monthly_individual_data = Array.new(12,0)
    individual = User.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and active = 1", :group => "yr, mon")
    individual.each do |f|
      monthly_individual_data[f.mon.to_i - 1] = f.count
    end
    monthly_individual_data
  end

  def self.get_company_monthly_signup_stats
    monthly_company_data = Array.new(12,0)
    company = Company.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW())", :group => "yr, mon")
    company.each do |p|
      monthly_company_data[p.mon.to_i - 1] = p.count
    end
    monthly_company_data
  end

  def self.get_free_user_weekly_signup_stats
    weekly_free_data = Array.new(DateTime.now().cweek.to_i,0)
    free = User.find(:all, :select => "YEAR(created_at) AS yr,WEEK(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and membership_id = 1 and active = 1", :group => "yr, mon")
    free.each do |f|
      weekly_free_data[f.mon.to_i - 1] = f.count
    end
    weekly_free_data
  end

  def self.get_premium_user_weekly_signup_stats
    weekly_premium_data = Array.new(DateTime.now().cweek.to_i,0)
    premium = User.find(:all, :select => "YEAR(created_at) AS yr,WEEK(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and membership_id = 2 and active = 1", :group => "yr, mon")
    premium.each do |p|
      weekly_premium_data[p.mon.to_i - 1] = p.count
    end
    weekly_premium_data
  end

  def self.get_individual_user_weekly_signup_stats
    weekly_individual_data = Array.new(DateTime.now().cweek.to_i,0)
    individual = User.find(:all, :select => "YEAR(created_at) AS yr,WEEK(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and active = 1", :group => "yr, mon")
    individual.each do |f|
      weekly_individual_data[f.mon.to_i - 1] = f.count
    end
    weekly_individual_data
  end

  def self.get_company_weekly_signup_stats
    weekly_company_data = Array.new(DateTime.now().cweek.to_i,0)
    company = Company.find(:all, :select => "YEAR(created_at) AS yr,WEEK(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW())", :group => "yr, mon")
    company.each do |p|
      weekly_company_data[p.mon.to_i - 1] = p.count
    end
    weekly_company_data
  end

  def self.get_free_user_quarterly_signup_stats
    monthly_free_data = Array.new(12,0)
    quarterly_free_data = Array.new(4,0)
    free = User.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and membership_id = 1 and active = 1", :group => "yr, mon")
    free.each do |f|
      monthly_free_data[f.mon.to_i - 1] = f.count
    end
    0.upto(3).each { |i| quarterly_free_data[i] = monthly_free_data[i*3].to_i + monthly_free_data[i*3 +1].to_i + monthly_free_data[i*3 +2].to_i }
    quarterly_free_data
  end

  def self.get_premium_user_quarterly_signup_stats
    monthly_premium_data = Array.new(12,0)
    quarterly_premium_data = Array.new(4,0)
    premium = User.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and membership_id = 2 and active = 1", :group => "yr, mon")
    premium.each do |p|
      monthly_premium_data[p.mon.to_i - 1] = p.count
    end
    0.upto(3).each { |i| quarterly_premium_data[i] = monthly_premium_data[i*3].to_i + monthly_premium_data[i*3 +1].to_i + monthly_premium_data[i*3 +2].to_i }
    quarterly_premium_data
  end

  def self.get_individual_user_quarterly_signup_stats
    monthly_individual_data = Array.new(12,0)
    quarterly_individual_data = Array.new(4,0)
    individual = User.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW()) and active = 1", :group => "yr, mon")
    individual.each do |f|
      monthly_individual_data[f.mon.to_i - 1] = f.count
    end
    monthly_individual_data
    0.upto(3).each { |i| quarterly_individual_data[i] = monthly_individual_data[i*3].to_i + monthly_individual_data[i*3 +1].to_i + monthly_individual_data[i*3 +2].to_i }
    quarterly_individual_data
  end

  def self.get_company_quarterly_signup_stats
    monthly_company_data = Array.new(12,0)
    quarterly_company_data = Array.new(4,0)
    company = Company.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,COUNT(*) as count", :conditions => "YEAR(created_at) = YEAR(NOW())", :group => "yr, mon")
    company.each do |p|
      monthly_company_data[p.mon.to_i - 1] = p.count
    end
    monthly_company_data
    0.upto(3).each { |i| quarterly_company_data[i] = monthly_company_data[i*3].to_i + monthly_company_data[i*3 +1].to_i + monthly_company_data[i*3 +2].to_i }
    quarterly_company_data
  end

  def self.get_all_users(searchword)
    @users = Array.new
    @users =  User.find(:all, :include => [:user_privacy_setting], :conditions => ['user_name LIKE ? AND user_privacy_settings.is_searchable = 1', "#{searchword}%"], :order => 'user_name')
    @companies = Brand.find(:all, :include => [:brand_privacy], :conditions => ['name LIKE ? AND brand_privacies.is_searchable = 1', "#{searchword}%"], :order => 'name')
    @users += @companies
  end

  def affiliations
    company_id_condition = self.company.blank? ? "brand_user_groups.status = 1" : "brand_user_groups.company_id != #{self.company.id} AND brand_user_groups.status = 1"
    self.brand_user_groups.find(:all, :include => [:company, :brand], :conditions => "#{company_id_condition}")
  end

  def has_company?
    self.company && self.check_payment_status?
  end

  def self.get_stats(membership_id = nil)
    unless membership_id.blank?
      User.count(:all, :conditions => ["users.active = 1 and users.membership_id in (?)", membership_id])
    else
      User.count(:all, :conditions => ["users.active = 1 and users.membership_id in (1,2)"])
    end

  end

  def get_status_service_ids
    ids = []
    self.active_services.link_sharing_services.each do |service|
      ids << service.id
    end
    ids.join(',')
  end

  def get_blog_service_ids
    ids = []
    self.active_services.blog_sharing_services.each do |service|
      ids << service.id
    end
    ids.join(',')
  end

  def get_video_service_ids
    ids = []
    self.active_services.video_sharing_services.each do |service|
      ids << service.id
    end
    ids.join(',')
  end

  def get_photo_service_ids
    ids = []
    self.active_services.photo_sharing_services.each do |service|
      ids << service.id
    end
    ids.join(',')
  end

  def update_timezone(request)
    geoip ||= GeoIP.new("#{RAILS_ROOT}/db/GeoLiteCity.dat")
    remote_ip = request.remote_ip
    if remote_ip != "127.0.0.1"
      location = geoip.country(remote_ip)
      unless location.blank?
        self.country = location.country_code2
        self.time_zone =  location.timezone
        self.save
      end
    end
  end

  #  def get_timezone
  #    geoip ||= GeoIP.new("#{RAILS_ROOT}/db/GeoLiteCity.dat")
  #    location = geoip.country("124.30.122.233")
  #    if location != nil
  #      time_zones = get_time_zones(location.country_code2)
  #      self.time_zone = time_zones[0] unless time_zones.blank?
  #      self.time_zone =  location.timezone
  #    end
  #  end

end
