class Service < ActiveRecord::Base

  #Associations
  #  has_and_belongs_to_many :users
  has_many :users, :through => :user_services
  has_many  :user_services
  has_and_belongs_to_many :posts
  belongs_to :service_category

  #Validations
  validates_presence_of :name, :url

  named_scope :services
  named_scope :social_networking_services, :conditions => "service_category_id = 1"
  named_scope :video_publishing_services, :conditions => "service_category_id = 2"
  named_scope :bookmarking_services, :conditions => "service_category_id = 3"
  named_scope :blogging_services, :conditions => "service_category_id = 4"
  named_scope :photo_sharing_services, :conditions => "service_category_id = 5"
  #Constants
  SERVICES_ID={
    :twitter => 1,
    :facebook => 2,
    :youtube => 3,
    :vimeo => 4,
    :delicious => 5,
    :stumbleupon => 6,
    :flickr => 7,
    :tumblr => 9,
    :facebook_page => 10
  }


  def service_configurations
    ServiceConfiguration.find(self.service_configuration_ids.split(",")) unless self.service_configuration_ids.blank?
  end
end
