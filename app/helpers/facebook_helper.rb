module FacebookHelper
  require 'facebook_oauth'
  APP_ID = "152688064798273"
  APP_SECRET_KEY = "2a0d1f86bb9462039bdc4fc265982ac7"
  
  def authenticate_fb_user(user_service = nil)
    if !@user_service.has_facebook_oauth?
      @link = fb_client.authorize_url(:scope => 'offline_access, publish_stream, user_status, read_stream')
      session["link"] = @link      
    end
    [fb_client]
  end

  def fb_client
    @client ||= FacebookOAuth::Client.new(
    :application_id => APP_ID,
    :application_secret => APP_SECRET_KEY,
    :callback => "http://edintity.com/user_sessions/facebook_callback?user_service_id=#{@user_service.id}"
    )
  end

  def authenticate_fb_page_user(user_service = nil)
    if !@user_service.has_facebook_oauth?
      @link = fb_client.authorize_url(:scope => 'offline_access, manage_pages, publish_stream')
      session["link"] = @link
    end
    [fb_client]
  end
  
end
