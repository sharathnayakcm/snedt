class SkinStyle < ActiveRecord::Base

  belongs_to :skin
  belongs_to :style_attribute
  belongs_to :panel_type
  has_many :assets, :as => :attachable
  
end
