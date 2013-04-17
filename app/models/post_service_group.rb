class PostServiceGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :post_type
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :user_service_ids, :message => "Please select services"

#  validate do |post_service_group|
#    post_service_group.errors.add_to_base("Please select at least a user group / user to add the custom tab") if post_service_group.user_service_ids.blank?
#  end
  
end
