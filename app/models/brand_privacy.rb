class BrandPrivacy < ActiveRecord::Base
  belongs_to :brand

  PRIVACY_TYPES = {
    "Everyone" => 1,
    "Brand Admin" => 2,
    "Brand Manager" => 3,
    "Content Manager" => 4
  }

end
