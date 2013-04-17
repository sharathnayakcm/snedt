class Tag < ActiveRecord::Base

  belongs_to :user
  has_many :stream_tags
  has_many :streams,:through => :stream_tags
  
end
