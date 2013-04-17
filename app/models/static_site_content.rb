class StaticSiteContent < ActiveRecord::Base

  validates_presence_of :title, :text_content
end
