class BrandUserGroup < ActiveRecord::Base

  belongs_to :user
  belongs_to :brand
  belongs_to :company

  #brand group permissions
  BrandAdmin = 2
  BrandManager = 3
  ContentManager = 4

    ACCESS_TYPES = {
    "Brand Admin" => 2,
    "Brand Manager" => 3,
    "Content Manager" => 4
  }

  def show_access_type
    if self.access_type == 2
      "Brand Admin"
    elsif  self.access_type == 3
      "Brand Manager"
    elsif  self.access_type == 4
      "Content Manager"
    end
  end

  def affiliation_brand
    self.brand.blank? ? self.company.default_brand : self.brand
  end

end
