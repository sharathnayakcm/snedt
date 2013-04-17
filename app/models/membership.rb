class Membership < ActiveRecord::Base

  #ACCOCIATIONS
  has_one :user
  has_one :company

  #NAMED SCOPES
  named_scope :active, :conditions => ["active = 1"]
  named_scope :individual, :conditions => ["membership_type = 'individual'"]
  named_scope :business, :conditions => ["membership_type = 'business'"]
  named_scope :paid_plans, :conditions => ["id != 1"]

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :amount, :upload_limit


  def display_upload_limit
    self.upload_limit.to_i > 250 ?  "#{self.upload_limit.to_i / 1024}Gb/mo" : "#{self.upload_limit.to_i}Mb/mo"
  end
end
