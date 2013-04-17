module TumblrHelper

  require 'oauth'
#	require 'omniauth'

	def tumblr_access_token(token, secret)  
    consumer = OAuth::Consumer.new('WbI41IN94GLiSkleeWpUbX7cys2xz3Ul6ioFSJs9Zni1ppnugm', 'NrWBAtzJq1XOkSERRygerdxxEOrmV3sbj5kmP9R5dSvlWiamUG',{:site => "http://www.tumblr.com/",
        :request_token_path => '/oauth/request_token',
        :authorize_path => '/oauth/authorize',
        :access_token_path => '/oauth/access_token',
        :http_method => :post})
    token_hash = {:oauth_token => token,:oauth_token_secret => secret}
    OAuth::AccessToken.from_hash(consumer, token_hash )
	end
  
  def authenticate_youtube_user
    client = GData::Client::YouTube.new
    next_url = 'http://edintity.com/youtube'
    secure = false  # set secure = true for signed AuthSub requests
    sess = true
    authsub_link = client.authsub_url(next_url, secure, sess)
  end

  def get_tumblr_consumer
    key = 'WbI41IN94GLiSkleeWpUbX7cys2xz3Ul6ioFSJs9Zni1ppnugm'
    secret = 'NrWBAtzJq1XOkSERRygerdxxEOrmV3sbj5kmP9R5dSvlWiamUG'
    site = 'http://www.tumblr.com'
    OAuth::Consumer.new(key, secret,
      { :site => site,
        :request_token_path => '/oauth/request_token',
        :authorize_path => '/oauth/authorize',
        :access_token_path => '/oauth/access_token',
        :http_method => :post})
  end
  
end
