module FlickrHelper
   
  def authenticate_flickr_user(user_service = nil)
    frob = flickr.auth.getFrob
    @link = FlickRaw.auth_url(:frob => frob, :perms => 'write')
    session["link"] = @link
    frob
  end
  
end
