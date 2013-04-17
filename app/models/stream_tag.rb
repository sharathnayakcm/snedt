class StreamTag < ActiveRecord::Base

  belongs_to :stream
  belongs_to :tag
  
end
