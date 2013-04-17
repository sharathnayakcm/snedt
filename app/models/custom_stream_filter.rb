class CustomStreamFilter < ActiveRecord::Base

  belongs_to :user
  belongs_to :post_type

  def self.get_streams(filter, user)
    #    if filter.stream_posted_date.blank?
    #      unless filter.stream_tags.to_s.split(',').blank?
    #        user.streams.find(:all, :include => [:sender, :tags], :conditions => ["streams.user_service_id in (?) and tags.name in (?)", filter.user_service_ids.to_s.split(','), filter.stream_tags.to_s.split(',')], :order => "stream_created_at DESC")
    #      else
    #        user.streams.find(:all, :include => [:sender], :conditions => ["streams.user_service_id in (?)", filter.user_service_ids.to_s.split(',')], :order => "stream_created_at DESC")
    #      end
    #    else
    unless (filter.stream_start_date.blank? && filter.stream_end_date.blank? )
      unless filter.stream_tags.to_s.split(',').blank?
        user.streams.find(:all, :include => [:sender, :tags], :conditions => ["streams.user_service_id in (?) and Date(stream_created_at) <= Date(?) and Date(stream_created_at) >= Date(?) and tags.name in (?)", filter.user_service_ids.to_s.split(','), filter.stream_end_date, filter.stream_start_date, filter.stream_tags.to_s.split(',')], :order => "stream_created_at DESC")
      else
        user.streams.find(:all, :include => [:sender], :conditions => ["streams.user_service_id in (?) and Date(stream_created_at) <= Date(?) and Date(stream_created_at) >= Date(?)", filter.user_service_ids.to_s.split(','), filter.stream_end_date, filter.stream_start_date], :order => "stream_created_at DESC")
      end

    else
      unless filter.stream_tags.to_s.split(',').blank?
        user.streams.find(:all, :include => [:sender, :tags], :conditions => ["streams.user_service_id in (?) and  tags.name in (?)", filter.user_service_ids.to_s.split(','),  filter.stream_tags.to_s.split(',')], :order => "stream_created_at DESC")
      else
        user.streams.find(:all, :include => [:sender], :conditions => ["streams.user_service_id in (?)", filter.user_service_ids.to_s.split(',')], :order => "stream_created_at DESC")
      end
    end
    #    end
  end
  
end
