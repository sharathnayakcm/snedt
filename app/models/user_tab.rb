class UserTab < ActiveRecord::Base
  belongs_to :user
  belongs_to :tab
end
