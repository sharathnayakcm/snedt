class TwitterAccount < ActiveRecord::Base
  belongs_to :user
  require 'twitter_oauth'
  TWITER_KEY = "zVwziK0AW1w5sTPCZ9v4Q"
  TWITER_SECRET_KEY = "rMX782DKERokrNEAlW1GmwBFOZUwx9XIHh8PvHb0syM"
  TWITTER_CALLBACK_URL = "http://edintity.com/user_sessions/callback"


  def self.receive_direct_messages(service)
    errors = ""
    if service.has_twitter_oauth?   
      @T_OAUTH = TwitterOAuth::Client.new( :consumer_key => TWITER_KEY,
        :consumer_secret => TWITER_SECRET_KEY, :token => service.token,
        :secret => service.secret )
      if @T_OAUTH.authorized? and @T_OAUTH.messages
        id = Stream.find_since_id(service.user,service)
        if !id.blank?          
          messages_hash = @T_OAUTH.messages({:since_id => id})
        else          
          messages_hash = @T_OAUTH.messages
        end
        [Stream.save_twitter_stream_details(messages_hash,service), ""]
      else
        errors = "Sorry ! Your tweet failed to sent, try later !"
        [[], errors]
      end
    else
      errors = "You dont have twitter account with oauth token, please authorize edintity in your twitter !"
      [[], errors]
    end
  end
  #TODO Code to be reviewed
  def self.receive_status_messages(service, brand )
    errors = ""
    if service.has_twitter_oauth?
      @T_OAUTH = TwitterOAuth::Client.new( :consumer_key => TWITER_KEY,
        :consumer_secret => TWITER_SECRET_KEY, :token => service.token,
        :secret => service.secret )
      if @T_OAUTH.authorized? and @T_OAUTH.messages
        if service.class != UserService
          id = Stream.find_since_id_brand(service.brand,service)
        else
          id = Stream.find_since_id(service.user,service)
        end
        if !id.blank? && id.to_i > 0
          messages_hash = @T_OAUTH.home_timeline({:since_id => id.to_i})
          messages_hash += @T_OAUTH.retweeted_by_me({:since_id => id.to_i})
        else
          messages_hash = @T_OAUTH.home_timeline
        end
        [Stream.save_twitter_status_stream_details(messages_hash,service,brand), ""]
      else
        errors = "Sorry ! Your tweet failed to sent, try later !"
        [[], errors]
      end
    else
      errors = "You dont have twitter account with oauth token, please authorize edintity in your twitter !"
      [[], errors]
    end
  end
  #end
  def self.post_twitter_message(message,service,star_count, retweet=false, stream = nil)
    errors = ""
    if service.has_twitter_oauth?
      @T_OAUTH = TwitterOAuth::Client.new( :consumer_key => TWITER_KEY,
        :consumer_secret => TWITER_SECRET_KEY, :token => service.token,
        :secret => service.secret )
      if @T_OAUTH.authorized?
        if retweet and @T_OAUTH.retweet(stream.stream_id)
          stream.update_attribute(:retweeted, true)
          [true, errors]
        elsif @T_OAUTH.update(message)
          #Stream.save_post_status_stream_details(service,@T_OAUTH.info,star_count,retweet)
          [true, errors]
        end
      else
        errors = "Sorry ! Your tweet failed to sent, try later !"
        [false, errors]
      end
    else
      errors = "You dont have twitter account with oauth token, please authorize edintity in your twitter !"
      [false, errors]
    end
  end

  def self.get_mentions(service, stream)
    if stream.sender
      if service.has_twitter_oauth?
        @T_OAUTH = TwitterOAuth::Client.new( :consumer_key => TWITER_KEY,
          :consumer_secret => TWITER_SECRET_KEY, :token => service.token,
          :secret => service.secret )
        if @T_OAUTH.authorized? and @T_OAUTH.messages
          messages_hash = @T_OAUTH.search("@#{stream.sender.user_name}")
          messages_hash
        else
          []
        end
      else
        []
      end
    end
  end

  def self.post_twitter_reply(stream,service,message)
    if stream.sender
      errors = ""
      if service.has_twitter_oauth?
        @T_OAUTH = TwitterOAuth::Client.new( :consumer_key => TWITER_KEY,
          :consumer_secret => TWITER_SECRET_KEY, :token => service.token,
          :secret => service.secret )
        if @T_OAUTH.authorized? and @T_OAUTH.update("@#{stream.sender.user_name} #{message}", {:in_reply_to_status_id => stream.stream_id})
          [true, errors, @T_OAUTH.info["status"]["id"]]
        else
          errors = "Sorry ! Your tweet failed to sent, try later !"
          [false, errors]
        end
      else
        errors = "You dont have twitter account with oauth token, please authorize edintity in your twitter !"
        [false, errors]
      end
    end
  end

end
