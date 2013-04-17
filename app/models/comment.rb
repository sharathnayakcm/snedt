class Comment < ActiveRecord::Base
  belongs_to :stream
  belongs_to :user

  def deliver_notification(profile_url,stream_url, locale)
    image_url = self.user.profile_image.blank? ? "http://edintity.com/avatars/original/missing.png" : self.user.profile_image.asset.url.gsub("/s3.","/s3-eu-west-1.")
    Notification.deliver_notification("Comment", self.stream.user, { "params" => {"friend_profile_url" => profile_url, "image_url" => image_url, "user_name" => self.user.user_name, "comment" => self.description, "stream" => self.stream.id, "stream_url" => stream_url}}, :locale => locale == "true") if self.stream.user.is_notifiable?("Comment")
  end

  def self.fb_comment_ids(stream_id)
    comment_ids = []
    comments = self.find_all_by_stream_id stream_id
    comments.each do |comment|
      comment_ids << comment["fb_comment_id"] unless comment["fb_comment_id"].blank?
    end
    comment_ids
  end

  def self.twitter_reply_ids(stream_id)
    comment_ids = []
    comments = self.find_all_by_stream_id stream_id
    comments.each do |comment|
      comment_ids << comment["twitter_reply_id"] unless comment["twitter_reply_id"].blank?
    end
    comment_ids
  end

end
