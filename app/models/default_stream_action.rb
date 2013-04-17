class DefaultStreamAction < ActiveRecord::Base

  belongs_to :user
  belongs_to :brand
  belongs_to :user_service

end
