class CompanyUserGroup < ActiveRecord::Base

  belongs_to :user
  belongs_to :company
  
  #company group permissions
  Admin = 1
  ContentManager = 3
end
