class CustomTab < ActiveRecord::Base
  belongs_to :user
  #  validates_presence_of :service_ids, :message => "Please select services"
#  validates_uniqueness_of :name

  validate do |custom_tab|
    custom_tab.errors.add_to_base("Please select at least a user group / user to add the custom tab") if custom_tab.filter_user_ids.blank? && custom_tab.user_type_ids.blank?
    custom_tab.errors.add_to_base("Tab name cannot be blank.") if custom_tab.name.blank?
  end

  def user_services
    UserService.find(:all, :include => [:service], :conditions => ["id in (?)", self.service_ids.split(",")])
  end

  def services
    Service.find(:all, :conditions => ["id in (?)", self.service_ids.split(",")])
  end

  def self.find_names(name,user)
    User.find(:all,:select => "id, user_name, full_name",  :conditions => "user_name Like '#{name}%' or full_name Like '#{name}%'")
  end

  def self.find_user_names(name,user)
    User.find(:all, :conditions => "(user_name Like '#{name}%' or full_name Like '#{name}%') and id != #{user.id}")
  end

end
