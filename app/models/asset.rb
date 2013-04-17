class Asset < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  belongs_to :user
  belongs_to :company

  validate :check_limit
  after_save :update_usage

  ACCESS_KEY_ID = 'AKIAI2774245UYOVXRWA'
  SECRET_ACCESS_KEY = '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'
  BUCKET = 'edintity'

  has_attached_file :asset,
    :storage => 's3',
    :server => 'edintity.s3.amazonaws.com',
    :bucket => BUCKET,
    :path => "uploads/:attachment/:id/:styles.:extension",
    :s3_credentials => {
    :access_key_id => ACCESS_KEY_ID,
    :secret_access_key => SECRET_ACCESS_KEY },
    :s3_permissions => 'public-read',
    :styles => {
    :thumb=> "100x100#",
    :small  => "150x150>" }
  has_attached_file :video,
    :storage => 's3',
    :server => 'edintity.s3.amazonaws.com',
    :bucket => BUCKET,
    :path => "uploads/:attachment/:id/:styles.:extension",
    :s3_credentials => {
    :access_key_id => ACCESS_KEY_ID,
    :secret_access_key => SECRET_ACCESS_KEY },
    :s3_permissions => 'public-read'
  validates_attachment_content_type :asset, :content_type => ['image/jpeg','image/png','image/gif','image/jpg','image/pjpeg']
  validates_attachment_size :asset, :in => 1..104857600
  #  validates_attachment_content_type :video, :content_type => ['video/x-flv']

  def rounded_size
    size = (self.asset_file_size * 10**2).round.to_f / 10**2
    "#{size} KB"
  end
  
  def check_limit
    if company
      user_usage = self.company.uploaded_size.to_i + self.asset_file_size.to_i
    else
      user_usage = self.user.uploaded_size.to_i + self.asset_file_size.to_i
    end
    upload_limit_in_bytes = self.user.membership.upload_limit.to_i * 1048576
    self.errors.add( "upload limit reached") if
    user_usage > upload_limit_in_bytes
  end

  def video_file_name
    
  end

  def update_usage
    if company
      self.company.update_attributes({:uploaded_size => self.company.uploaded_size.to_i + self.asset_file_size.to_i + self.video_file_size.to_i })
    else
      self.user.update_attributes({:uploaded_size => self.user.uploaded_size.to_i + self.asset_file_size.to_i + self.video_file_size.to_i})
    end
  end

  def self.user_usage
    assets = self.sum(:asset_file_size, :conditions => "user_id is not null and company_id is null and attachable_type = 'Stream'")
    videos = self.sum(:video_file_size, :conditions => "user_id is not null and company_id is null and attachable_type = 'Stream'")
    assets.to_i + videos.to_i
  end

  def self.company_usage
    assets = self.sum(:asset_file_size, :conditions => "company_id is not null and attachable_type = 'Stream'")
    videos = self.sum(:video_file_size, :conditions => "company_id is not null and attachable_type = 'Stream'")
    assets.to_i + videos.to_i
  end

  def self.get_overall_service_usage_stats
    overall_service_usage_data = {"Facebook" => 0, "Youtube" => 0, "Vimeo" => 0, "Flickr" => 0, "Tumblr" => 0}
    assets = Asset.find(:all, :select=> "id, attachable_id,attachable_type,asset_file_size,video_file_size", :conditions => "attachable_type = 'Stream'", :include => :attachable)
    get_service_user_services
    assets.each do |asset|
      if (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @facebook_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_facebook_services).blank?)
        overall_service_usage_data["Facebook"] = overall_service_usage_data["Facebook"] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @youtube_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_youtube_services).blank?)
        overall_service_usage_data["Youtube"] = overall_service_usage_data["Youtube"] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @vimeo_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_vimeo_services).blank?)
        overall_service_usage_data["Vimeo"] = overall_service_usage_data["Vimeo"] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @flickr_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_flickr_services).blank?)
        overall_service_usage_data["Flickr"] = overall_service_usage_data["Flickr"] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @tumblr_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_tumblr_services).blank?)
        overall_service_usage_data["Tumblr"] = overall_service_usage_data["Tumblr"] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      end
    end
    overall_service_usage_data
  end

  def self.get_service_user_services
    @facebook_services = UserService.facebook_services.collect{|x| x.id.to_s}
    @youtube_services = UserService.youtube_services.collect{|x| x.id.to_s}
    @vimeo_services = UserService.vimeo_services.collect{|x| x.id.to_s}
    @flickr_services = UserService.flickr_services.collect{|x| x.id.to_s}
    @tumblr_services = UserService.tumblr_services.collect{|x| x.id.to_s}
    @brand_facebook_services = BrandService.facebook_services.collect{|x| x.id.to_s}
    @brand_youtube_services = BrandService.youtube_services.collect{|x| x.id.to_s}
    @brand_vimeo_services = BrandService.vimeo_services.collect{|x| x.id.to_s}
    @brand_flickr_services = BrandService.flickr_services.collect{|x| x.id.to_s}
    @brand_tumblr_services = BrandService.tumblr_services.collect{|x| x.id.to_s}
  end

  def self.get_user_monthly_usage_stats
    monthly_user_usage_data = Array.new(12,0)
    usage = Asset.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,SUM(asset_file_size) as asset_size, SUM(video_file_size) as video_size", :conditions => "YEAR(created_at) = YEAR(NOW()) and user_id is not null and company_id is null and attachable_type = 'Stream'", :group => "yr, mon")
    usage.each do |f|
      size = f.asset_size.to_i + f.video_size.to_i
      monthly_user_usage_data[f.mon.to_i - 1] = ((size.to_i/1024/1024.0)*1000).round.to_f/1000
    end
    monthly_user_usage_data
  end

  def self.get_company_monthly_usage_stats
    monthly_company_usage_data = Array.new(12,0)
    usage = Asset.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,SUM(asset_file_size) as asset_size, SUM(video_file_size) as video_size", :conditions => "YEAR(created_at) = YEAR(NOW()) and company_id is not null and attachable_type = 'Stream'", :group => "yr, mon")
    usage.each do |f|
      size = f.asset_size.to_i + f.video_size.to_i
      monthly_company_usage_data[f.mon.to_i - 1] = ((size.to_i/1024/1024.0)*1000).round.to_f/1000
    end
    monthly_company_usage_data
  end

  def self.get_service_monthly_usage_stats
    facebook_usage_data = Array.new(12,0)
    youtube_usage_data = Array.new(12,0)
    vimeo_usage_data = Array.new(12,0)
    flickr_usage_data = Array.new(12,0)
    tumblr_usage_data = Array.new(12,0)
    get_service_user_services
    assets = Asset.find(:all, :select=> "id, attachable_id,attachable_type,MONTH(created_at) as month,asset_file_size,video_file_size", :conditions=>"YEAR(created_at) = YEAR(NOW()) and attachable_type = 'Stream'")
    assets.each do |asset|
      if (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @facebook_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_facebook_services).blank?)
        facebook_usage_data[asset.month.to_i - 1] = facebook_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @youtube_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_youtube_services).blank?)
        youtube_usage_data[asset.month.to_i - 1] = youtube_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @vimeo_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_vimeo_services).blank?)
        vimeo_usage_data[asset.month.to_i - 1] = vimeo_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @flickr_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_flickr_services).blank?)
        flickr_usage_data[asset.month.to_i - 1] = flickr_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @tumblr_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_tumblr_services).blank?)
        tumblr_usage_data[asset.month.to_i - 1] = tumblr_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      end
    end
    monthly_service_usage_data = {"Facebook" => facebook_usage_data, "Youtube" => youtube_usage_data, "Vimeo" => vimeo_usage_data, "Flickr" => flickr_usage_data, "Tumblr" => tumblr_usage_data}
    monthly_service_usage_data
  end

  def self.get_user_weekly_usage_stats
    weekly_user_usage_data = Array.new(DateTime.now().cweek.to_i,0)
    user = Asset.find(:all, :select => "YEAR(created_at) AS yr,WEEK(created_at) AS mon,SUM(asset_file_size) as asset_size, SUM(video_file_size) as video_size", :conditions => "YEAR(created_at) = YEAR(NOW()) and user_id is not null and company_id is null and attachable_type = 'Stream'", :group => "yr, mon")
    user.each do |f|
      size = f.asset_size.to_i + f.video_size.to_i
      weekly_user_usage_data[f.mon.to_i - 1] = ((size.to_i/1024/1024.0)*1000).round.to_f/1000
    end
    weekly_user_usage_data
  end

  def self.get_company_weekly_usage_stats
    weekly_company_usage_data = Array.new(DateTime.now().cweek.to_i,0)
    company = Asset.find(:all, :select => "YEAR(created_at) AS yr,WEEK(created_at) AS mon,SUM(asset_file_size) as asset_size, SUM(video_file_size) as video_size", :conditions => "YEAR(created_at) = YEAR(NOW()) and company_id is not null and attachable_type = 'Stream'", :group => "yr, mon")
    company.each do |f|
      size = f.asset_size.to_i + f.video_size.to_i
      weekly_company_usage_data[f.mon.to_i - 1] = ((size.to_i/1024/1024.0)*1000).round.to_f/1000
    end
    weekly_company_usage_data
  end

  def self.get_service_weekly_usage_stats
    facebook_usage_data = Array.new(DateTime.now().cweek.to_i,0)
    youtube_usage_data = Array.new(DateTime.now().cweek.to_i,0)
    vimeo_usage_data = Array.new(DateTime.now().cweek.to_i,0)
    flickr_usage_data = Array.new(DateTime.now().cweek.to_i,0)
    tumblr_usage_data = Array.new(DateTime.now().cweek.to_i,0)
    get_service_user_services
    assets = Asset.find(:all, :select=> "id, attachable_id,attachable_type,WEEK(created_at) as week,asset_file_size,video_file_size", :conditions=>"YEAR(created_at) = YEAR(NOW()) and attachable_type = 'Stream'")
    assets.each do |asset|
      if (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @facebook_services.to_a).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_facebook_services.to_a).blank?)
        facebook_usage_data[asset.week.to_i - 1] = facebook_usage_data[asset.week.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @youtube_services.to_a).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_youtube_services.to_a).blank?)
        youtube_usage_data[asset.week.to_i - 1] = youtube_usage_data[asset.week.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @vimeo_services.to_a).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_vimeo_services.to_a).blank?)
        vimeo_usage_data[asset.week.to_i - 1] = vimeo_usage_data[asset.week.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @flickr_services.to_a).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_filckr_services.to_a).blank?)
        flickr_usage_data[asset.week.to_i - 1] = flickr_usage_data[asset.week.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @tumblr_services.to_a).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_tumblr_services.to_a).blank?)
        tumblr_usage_data[asset.week.to_i - 1] = tumblr_usage_data[asset.week.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      end
    end
    weekly_service_usage_data = {"Facebook" => facebook_usage_data, "Youtube" => youtube_usage_data, "Vimeo" => vimeo_usage_data, "Flickr" => flickr_usage_data, "Tumblr" => tumblr_usage_data}
    weekly_service_usage_data
  end

  def self.get_user_quarterly_usage_stats
    monthly_user_usage_data = Array.new(12,0)
    quarterly_user_usage_data = Array.new(4,0)
    user = Asset.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,SUM(asset_file_size) as asset_size, SUM(video_file_size) as video_size", :conditions => "YEAR(created_at) = YEAR(NOW()) and user_id is not null and company_id is null and attachable_type = 'Stream'", :group => "yr, mon")
    user.each do |f|
      size = f.asset_size.to_i + f.video_size.to_i
      monthly_user_usage_data[f.mon.to_i - 1] = ((size.to_i/1024/1024.0)*1000).round.to_f/1000
    end
    0.upto(3).each { |i| quarterly_user_usage_data[i] = monthly_user_usage_data[i*3].to_f + monthly_user_usage_data[i*3 +1].to_f + monthly_user_usage_data[i*3 +2].to_f }
    quarterly_user_usage_data
  end

  def self.get_company_quarterly_usage_stats
    monthly_company_usage_data = Array.new(12,0)
    quarterly_company_usage_data = Array.new(4,0)
    company = Asset.find(:all, :select => "YEAR(created_at) AS yr,MONTH(created_at) AS mon,SUM(asset_file_size) as asset_size, SUM(video_file_size) as video_size", :conditions => "YEAR(created_at) = YEAR(NOW()) and company_id is not null and attachable_type = 'Stream'", :group => "yr, mon")
    company.each do |f|
      size = f.asset_size.to_i + f.video_size.to_i
      monthly_company_usage_data[f.mon.to_i - 1] = ((size.to_i/1024/1024.0)*1000).round.to_f/1000
    end
    0.upto(3).each { |i| quarterly_company_usage_data[i] = monthly_company_usage_data[i*3].to_f + monthly_company_usage_data[i*3 +1].to_f + monthly_company_usage_data[i*3 +2].to_f }
    quarterly_company_usage_data
  end

  def self.get_service_quarterly_usage_stats
    facebook_usage_data = Array.new(12,0)
    youtube_usage_data = Array.new(12,0)
    vimeo_usage_data = Array.new(12,0)
    flickr_usage_data = Array.new(12,0)
    tumblr_usage_data = Array.new(12,0)
    facebook_quarterly_usage_data = Array.new(4,0)
    youtube_quarterly_usage_data = Array.new(4,0)
    vimeo_quarterly_usage_data = Array.new(4,0)
    flickr_quarterly_usage_data = Array.new(4,0)
    tumblr_quarterly_usage_data = Array.new(4,0)
    get_service_user_services
    assets = Asset.find(:all, :select=> "id, attachable_id,attachable_type,MONTH(created_at) as month,asset_file_size,video_file_size", :conditions=>"YEAR(created_at) = YEAR(NOW()) and attachable_type = 'Stream'")
    assets.each do |asset|
      if (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @facebook_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_facebook_services).blank?)
        facebook_usage_data[asset.month.to_i - 1] = facebook_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @youtube_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_youtube_services).blank?)
        youtube_usage_data[asset.month.to_i - 1] = youtube_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @vimeo_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_vimeo_services).blank?)
        vimeo_usage_data[asset.month.to_i - 1] = vimeo_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @flickr_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_flickr_services).blank?)
        flickr_usage_data[asset.month.to_i - 1] = flickr_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @tumblr_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_tumblr_services).blank?)
        tumblr_usage_data[asset.month.to_i - 1] = tumblr_usage_data[asset.month.to_i - 1] + asset.asset_file_size.to_i + asset.video_file_size.to_i
      end
    end
    0.upto(3).each { |i| facebook_quarterly_usage_data[i] = facebook_usage_data[i*3].to_f + facebook_usage_data[i*3 +1].to_f + facebook_usage_data[i*3 +2].to_f }
    0.upto(3).each { |i| youtube_quarterly_usage_data[i] = youtube_usage_data[i*3].to_f + youtube_usage_data[i*3 +1].to_f + youtube_usage_data[i*3 +2].to_f }
    0.upto(3).each { |i| vimeo_quarterly_usage_data[i] = vimeo_usage_data[i*3].to_f + vimeo_usage_data[i*3 +1].to_f + vimeo_usage_data[i*3 +2].to_f }
    0.upto(3).each { |i| flickr_quarterly_usage_data[i] = flickr_usage_data[i*3].to_f + flickr_usage_data[i*3 +1].to_f + flickr_usage_data[i*3 +2].to_f }
    0.upto(3).each { |i| tumblr_quarterly_usage_data[i] = tumblr_usage_data[i*3].to_f + tumblr_usage_data[i*3 +1].to_f + tumblr_usage_data[i*3 +2].to_f }
    quarterly_user_usage_data = {"Facebook" => facebook_quarterly_usage_data, "Youtube" => youtube_quarterly_usage_data, "Vimeo" => vimeo_quarterly_usage_data, "Flickr" => flickr_quarterly_usage_data, "Tumblr" => tumblr_quarterly_usage_data}
    quarterly_user_usage_data
  end

  def self.get_service_usage_stats(start_date, end_date)
    facebook_usage_data = [[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date).to_i*1000, 0]]
    youtube_usage_data = [[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date).to_i*1000, 0]]
    vimeo_usage_data = [[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date).to_i*1000, 0]]
    flickr_usage_data = [[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date).to_i*1000, 0]]
    tumblr_usage_data = [[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date).to_i*1000, 0]]
    get_service_user_services
    assets = Asset.find(:all, :select=> "id, attachable_id,attachable_type,Date(created_at) as date,SUM(asset_file_size) as asset_size,SUM(video_file_size) as video_size", :conditions=>["created_at >= ? and created_at <= ? and attachable_type = 'Stream'", start_date, end_date], :group => "date")
    assets.each do |asset|
      if (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @facebook_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_facebook_services).blank?)
        facebook_usage_data << [DateTime.parse(asset.date).to_i*1000, (((asset.asset_size.to_i + asset.video_size.to_i).to_i/1024/1024.0)*1000).round.to_f/1000]
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @youtube_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_youtube_services).blank?)
        youtube_usage_data << [DateTime.parse(asset.date).to_i*1000, (((asset.asset_size.to_i + asset.video_size.to_i).to_i/1024/1024.0)*1000).round.to_f/1000]
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @vimeo_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_vimeo_services).blank?)
        vimeo_usage_data << [DateTime.parse(asset.date).to_i*1000, (((asset.asset_size.to_i + asset.video_size.to_i).to_i/1024/1024.0)*1000).round.to_f/1000]
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @flickr_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_flickr_services).blank?)
        flickr_usage_data << [DateTime.parse(asset.date).to_i*1000, (((asset.asset_size.to_i + asset.video_size.to_i).to_i/1024/1024.0)*1000).round.to_f/1000]
      elsif (asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @tumblr_services).blank?) || (!asset.attachable.brand_id.blank? && !(asset.attachable.send_to.to_a & @brand_tumblr_services).blank?)
        tumblr_usage_data << [DateTime.parse(asset.date).to_i*1000, (((asset.asset_size.to_i + asset.video_size.to_i).to_i/1024/1024.0)*1000).round.to_f/1000]
      end
    end
    service_usage_data = {"Facebook" => facebook_usage_data, "Youtube" => youtube_usage_data, "Vimeo" => vimeo_usage_data, "Flickr" => flickr_usage_data, "Tumblr" => tumblr_usage_data}
    service_usage_data
  end

  def self.get_user_usage_stats(start_date, end_date, table_view = false)
    unless table_view
      data = {}
      Membership.individual.each do |membership|
        data[membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      end
      individual_usage = Asset.find(:all, :joins => [:user], :select => "Date(assets.created_at) as date, assets.asset_file_size as asset_size, assets.video_file_size as video_size, user_id", :conditions => ["assets.created_at >= ? and assets.created_at <= ? and assets.user_id is not null and assets.company_id is null and assets.attachable_type = 'Stream' and users.membership_id in (1,2)", start_date, end_date])
      individual_usage.each do |usage|
        data[usage.user.membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[usage.user.membership.name].nil?
        data[usage.user.membership.name][DateTime.parse(usage.date).to_i*1000] = [] if data[usage.user.membership.name][DateTime.parse(usage.date).to_i*1000].blank?
        data[usage.user.membership.name][DateTime.parse(usage.date).to_i*1000] << (((usage.asset_size.to_i + usage.video_size.to_i).to_i/1024/1024.0)*1000).round.to_f/1000
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values, true)]
    else
      individual_usage = Asset.find(:all, :joins => [{:user => [:membership]}], :select => "Date(assets.created_at) as date, sum(ifnull(assets.asset_file_size, 0) + ifnull(assets.video_file_size, 0)) as asset_size, user_id, memberships.name as membership_name", :conditions => ["assets.created_at >= ? and assets.created_at <= ? and assets.user_id is not null and assets.company_id is null and assets.attachable_type = 'Stream' and users.membership_id in (1,2)", start_date, end_date], :group => "date, users.membership_id")
    end
  end

  def self.get_company_usage_stats(start_date, end_date, table_view = false)
    unless table_view
      data = {}
      Membership.business.each do |membership|
        data[membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      end
      individual_usage = Asset.find(:all, :joins => [:company], :select => "Date(assets.created_at) as date, assets.asset_file_size as asset_size, assets.video_file_size as video_size, company_id", :conditions => ["assets.created_at >= ? and assets.created_at <= ? and assets.company_id is not null and assets.attachable_type = 'Stream' and companies.membership_id in (3,4,5)", start_date, end_date])
      individual_usage.each do |usage|
        data[usage.company.membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[usage.company.membership.name].nil?
        data[usage.company.membership.name][DateTime.parse(usage.date).to_i*1000] = [] if data[usage.company.membership.name][DateTime.parse(usage.date).to_i*1000].blank?
        data[usage.company.membership.name][DateTime.parse(usage.date).to_i*1000] << (((usage.asset_size.to_i + usage.video_size.to_i).to_i/1024/1024.0)*1000).round.to_f/1000
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values, true)]
    else
      individual_usage = Asset.find(:all, :joins => [{:company => [:membership]}], :select => "Date(assets.created_at) as date, sum(ifnull(assets.asset_file_size, 0) + ifnull(assets.video_file_size, 0)) as asset_size, company_id, memberships.name as membership_name", :conditions => ["assets.created_at >= ? and assets.created_at <= ? and assets.company_id is not null and assets.attachable_type = 'Stream' and companies.membership_id in (3,4,5)", start_date, end_date], :group => "date, companies.membership_id")
    end
  end
  
  def self.get_post_method_usage_stats(start_date, end_date, table_view = false)
    unless table_view
      usage_data = {}
      usage_data["Photo"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      usage_data["Video"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      asset_usage = Asset.find(:all, :select => "Date(assets.created_at) as date, assets.asset_file_size as photo_size, assets.video_file_size as video_size", :conditions => ["assets.created_at >= ? and assets.created_at <= ? and assets.attachable_type = 'Stream'", start_date, end_date])
      asset_usage.each do |usage|
        if usage.photo_size.to_i > 0
          usage_data["Photo"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if usage_data["Photo"].nil?
          usage_data["Photo"][DateTime.parse(usage.date).to_i*1000] = [] if usage_data["Photo"][DateTime.parse(usage.date).to_i*1000].blank?
          usage_data["Photo"][DateTime.parse(usage.date).to_i*1000] << ((usage.photo_size.to_i/1024/1024.0)*1000).round.to_f/1000
        end
        if usage.video_size.to_i > 0
          usage_data["Video"] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if usage_data["Video"].nil?
          usage_data["Video"][DateTime.parse(usage.date).to_i*1000] = [] if usage_data["Video"][DateTime.parse(usage.date).to_i*1000].blank?
          usage_data["Video"][DateTime.parse(usage.date).to_i*1000] << ((usage.video_size.to_i/1024/1024.0)*1000).round.to_f/1000
        end
      end
      usage_data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [usage_data.keys, Brand.flatten(usage_data.values, true)]
    else
      Asset.find(:all, :select => "Date(assets.created_at) as date, sum(ifnull(assets.asset_file_size, 0)) as photo_size, sum(ifnull(assets.video_file_size, 0)) as video_size", :conditions => ["assets.created_at >= ? and assets.created_at <= ? and assets.attachable_type = 'Stream'", start_date, end_date], :group => "date")
    end
  end

  def self.convert_video(original_filename, stream_id)
    directory = RAILS_ROOT + "/" + "uploads"
    path = File.join(directory, original_filename)
    # create the file path
    upload_file = File.open(path, "r")
    ext = File.extname(upload_file.original_filename)
    if ext == ".flv" || ext == ".mov" 
      success = true
      new_flv = File.join(directory, original_filename)
    else
      filename = "#{Time.now.to_i}_#{stream_id}.flv"
      flv = File.join(directory, filename)
      File.open(flv, 'w')

      command = <<-end_command
        ffmpeg -i #{ path } -ar 22050  -s 480x360 -vcodec flv -r 25 -qscale 8 -f flv -y #{ flv }
      end_command
      command.gsub!(/\s+/, " ")
      success = system(command)
      new_flv = File.join(directory, filename)
      check_converted_file = File.open(new_flv)
      if check_converted_file.size == 0
#        File.delete(new_flv)
        filename = "#{Time.now.to_i}_#{stream_id}.flv"
        flv = File.join(directory, filename)
        File.open(flv, 'w')
        command = <<-end_command
          mencoder #{ path }  -o #{ flv } -of lavf -oac mp3lame -lameopts abr:br=56 -srate 22050 -ovc lavc -lavcopts vcodec=flv:vbitrate=500:mbd=2:mv0:trell:v4mv:cbp:last_pred=3
        end_command
        command.gsub!(/\s+/, " ")
        success = system(command)
        new_flv = File.join(directory, filename)
      end
#      File.delete(path)
    end
    [success, File.open(new_flv, 'r'), new_flv]
  end

end
