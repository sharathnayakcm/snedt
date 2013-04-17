module VimeoHelper
  require 'vimeo'
  VIMEO_CONSUMER_KEY = "574635b9dd84d078557c32e2e96911de"
  VIMEO_CONSUMER_SECRET = "7d717f5ef44a4426"

  def authenticate_vimeo_user
    if !@user_service.has_twitter_oauth?
      base = Vimeo::Advanced::Base.new(VIMEO_CONSUMER_KEY, VIMEO_CONSUMER_SECRET)
      request_token = base.get_request_token
      session[:oauth_secret] = request_token.secret
      base
    end
  end
end