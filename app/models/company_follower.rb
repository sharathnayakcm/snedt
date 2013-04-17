class CompanyFollower < ActiveRecord::Base
  #Associations
  belongs_to :user
  belongs_to :brand

end
