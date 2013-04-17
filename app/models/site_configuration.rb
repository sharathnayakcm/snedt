class SiteConfiguration < ActiveRecord::Base

  def self.violation_limit
    self.find(:first, :conditions => ["code = 'violation_limit'"])
  end
end
