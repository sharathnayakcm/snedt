class SavedSearch < ActiveRecord::Base
  belongs_to :user
#  validates_uniqueness_of :search_for
#  named_scope :saved_searches , :conditions => "user_id = '#{#current_user}'"
end
