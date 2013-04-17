module TwitsHelper
  require 'twitter_oauth'
  TWITER_KEY = "zVwziK0AW1w5sTPCZ9v4Q"
  TWITER_SECRET_KEY = "rMX782DKERokrNEAlW1GmwBFOZUwx9XIHh8PvHb0syM"
  TWITTER_CALLBACK_URL = "http://edintity.com/user_sessions/callback"

  def authenticate_user(user_service = nil)
    #TODO Check the condition (it should be designed in such a way that if the application is removed
    #FIXME the current_user's twitter_account should also be destroyed
    #    auth_object = user_service.blank? ? current_user : user_service
    if !@user_service.has_twitter_oauth?
      @T_OAUTH =TwitterOAuth::Client.new(:consumer_key => TWITER_KEY,:consumer_secret => TWITER_SECRET_KEY)
      @T_REQUEST_TOKEN = @T_OAUTH.request_token :oauth_callback => "http://edintity.com/user_sessions/callback?user_service_id=#{@user_service.id}"
      @T_TOKEN = @T_REQUEST_TOKEN.token
      @T_SECRET = @T_REQUEST_TOKEN.secret
      @link = @T_REQUEST_TOKEN.authorize_url
      session["link"] = @link
      session["token"] = @T_TOKEN
      session["secret"] = @T_SECRET
    end
  end


end
