class Badge < ActiveRecord::Base
  attr_accessible :name
  has_one :asset, :as => :attachable
end
