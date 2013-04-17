class UserUpgrade < ActiveRecord::Base
  belongs_to :user
  belongs_to :from_membership, :class_name => "Membership", :foreign_key => "from_membership_id"
  belongs_to :to_membership, :class_name => "Membership", :foreign_key => "to_membership_id"
end
