class PostsController < ApplicationController
  require 'open-uri'
  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  before_filter :current_company
  
  skip_before_filter :verify_authenticity_token, :only =>:upload

  def create
    # TODO: Move this piece of code into new action.
    @brand = Brand.find_by_id(params[:brand_type]) unless params[:brand_type].blank?
    if @brand && current_user.company && !current_user.company.active
      render :update do |page|
        page << "notice('#{t :company_inactive}')"
      end
    else
      @scope = params[:scope]
      case params[:stream_post_type].upcase
      when "STATUS" then
        params[:status_update_message] = params[:status_update_message] == "What are you doing?" ? "" : params[:status_update_message]
        if params[:status_update_message].strip == ""
          render :update do |page|
            page << "notice('#{t :empty_status}')"
          end
        else
          post_status
        end
      when "PHOTO" then
        post_photo
      when "VIDEO" then
        post_video
      when "LINK"  then
        if params[:stream_tags].to_a.size > 5
          render :update do |page|
            page << "notice('#{t :tag_limit}')"
          end
        else
          if validate_link(params[:title])
            post_link
          else
            render :update do |page|
              page << "notice('#{t :invalid_link}')"
            end
          end
        end
      when "BLOG"  then
        params[:blog_content] = params[:blog_content] == "Write Your blog content here..." ? "" : params[:blog_content]
        if params[:blog_content].strip == ""
          render :update do |page|
            page << "notice('#{t :empty_blog}')"
          end
        else
          post_blog
        end
      else
        render :update do |page|
          page << "notice('#{t :select_post_type}')"
        end
      end
    end
  end

  def post_status
    @unread_items = current_user.streams.unread_items.count
    user_service_list = []
    service_list = []
    unless params[:post_group_user_service_id].blank?
      post_user_list = params[:post_group_user_service_id]*(",")
      user_service_list = params[:serviceid].to_a.concat(post_user_list.split(",")).uniq
    else
      user_service_list = params[:serviceid].to_a
    end
    stream = Stream.save_edintity_stream_details(params, current_user, service_list,user_service_list)
    unless user_service_list.blank?
      unless params[:scope]
        service_list = UserService.find(user_service_list).collect{|x| x.service_id}
        brand = false
      else
        service_list = BrandService.find(user_service_list).collect{|x| x.service_id}
        brand = true
      end
      @post = Post.new
      @post.save_message(params,current_user,1)
      unless user_service_list == []
        params["stream"] = stream
        Post.post_to_services(params,current_user,user_service_list,brand)
      end
    end
    #stream = Stream.save_edintity_stream_details(params, current_user, service_list,user_service_list)
    unless params[:tag_name].blank?
      add_tag(stream)
    end
    #    if @brand.blank?
    #      @streams = current_user.streams.not_displayed
    #    else
    #      @streams = @brand.streams.not_displayed_for_brands
    #    end

    render :update do |page|
      #      page.insert_html :top, "stream_content",:partial => "streams/index", :locals => {:streams => [stream], :posted => true}
      #      page << "$('postStatus').reset();$j('.shareServiceControl').hide();$j('#{}shortURL').hide();$j('#status_update_message').val('')"
      #      page << "notice('#{t :stream_posted}')"
      page.redirect_to(home_path)
    end
    #    @streams.each do |stream|
    #      stream.is_displayed = 1
    #      stream.save
    #    end
  end

  def post_blog
    @post = Post.new
    @post.save_message(params,current_user,9)
    @errors = []
    services = []
    unless params[:post_group_user_service_id].blank?
      post_user_list = params[:post_group_user_service_id]*(",")
      services = params[:serviceid].to_a.concat(post_user_list.split(",")).uniq
    else
      services = params[:serviceid].to_a
    end
    unless services.blank?
      current_user.user_services.each do |service|
        if services.include?(service.id.to_s)
          if service.service_id == 9
            begin
              user = Tumblr::User.new(params["tumblr_email_#{service.id}"], params["tumblr_password_#{service.id}"])
              Tumblr.blog = service.token
              Tumblr::Post.create(user, :type => 'regular', :title => params[:blog_title], :body => params[:blog_content])
            rescue Exception => e
              @errors << service.token
            end
          else
            Post.post_blog_to_service(params,service)
          end
        end
      end
    end
    stream = Stream.save_edintity_blog_stream_details(params, current_user, "regular", services)
    notice = @errors.length > 0 ? "Blog could not be posted to Tumblr accounts (#{@errors * ','}) due to authentication failure" : "#{t :stream_posted}"
    render :update do |page|
      page.insert_html :top, "stream_content",:partial => "streams/index", :locals => {:streams => [stream], :posted => true}
      page << "notice('#{notice}')"
      page << "$('postBlog').reset();$j('.shareServiceControl').hide();$j('#blog_title').val('');$j('#blog_content').val('')"
    end
  end

  def post_link
    user_service_list = []
    service_list = []
    unless params[:post_group_user_service_id].blank?
      post_user_list = params[:post_group_user_service_id]*(",")
      user_service_list = params[:serviceid].to_a.concat(post_user_list.split(",")).uniq
    else
      user_service_list = params[:serviceid].to_a
    end
    if params[:short_link]
      params[:title] , error_message = shorten_with_bitly(params[:title])
    end
    unless user_service_list.blank?
      unless params[:scope]
        service_list = UserService.find(user_service_list).collect{|x| x.service_id}
        brand = false
      else
        service_list = BrandService.find(user_service_list).collect{|x| x.service_id}
        brand = true
      end
      @post = Post.new
      @post.save_link(params,current_user)
      unless user_service_list == []
        Post.post_to_services(params,current_user,user_service_list,brand)
      end
    end
    stream = Stream.save_edintity_link_stream_details(params, current_user, service_list,user_service_list)
    unless params[:stream_tags].blank?
      params[:stream_tags].each do |tag|
        existing = current_user.tags.find_by_name(tag)
        unless existing.blank?
          stream.stream_tags.create(:tag_id => existing.id)
        else
          new = current_user.tags.create(:name => tag)
          stream.stream_tags.create(:tag_id => new.id)
        end
      end
    end
    render :update do |page|
      page.insert_html :top, "stream_content",:partial => "streams/index", :locals => {:streams => [stream], :posted => true}
      page << "$('postLink').reset();$j('.shareServiceControl').hide();$j('#linkDescription').val('')"
      page << "notice('#{t :link_posted}')"
    end
  end

  def post_photo
    @unread_items = current_user.streams.unread_items.count
    @post = Post.new
    @post.save_message(params,current_user,7)
    asset = Asset.find_by_id(params[:asset_id])
    user_service_list = []
    unless params[:post_group_user_service_id].blank?
      post_user_list = params[:post_group_user_service_id]*(",")
      user_service_list = params[:serviceid].to_a.concat(post_user_list.split(",")).uniq
    else
      user_service_list = params[:serviceid].to_a
    end
    if asset
      stream = Stream.save_edintity_photo_stream_details(params, current_user, user_service_list)
      if user_service_list
        unless params[:scope]
          @service = current_user.user_services
        else
          brand = Brand.find_by_id(params[:brand_id])
          @service = brand.brand_services
        end
        @service.flickr_authorized.each do |service|
          if service.service_id.to_i == 7
            if user_service_list.include?(service.id.to_s) && flickr.auth.checkToken(:auth_token => service.token) && (photo_id = flickr.upload_photo params[:stream_image_url], :title => params[:title], :description => params[:description])
              info = flickr.photos.getInfo(:photo_id => photo_id)
            end
          else
            if user_service_list.include?(service.id.to_s)
              url = params[:stream_image_url]
              upload_file = open(URI.parse(params[:stream_image_url]))
              Post.post_photo_to_service(params,service,upload_file,url,stream)
            end
          end
        end
      end
      asset.update_attributes({:attachable_id => stream.id, :attachable_type => "Stream"})
      asset.update_usage
      stream.update_attributes(:stream_created_at => Time.current)
      @upload_setting = UploadSetting.first
      render :update do |page|
        page << "jQuery('#photoPreview').addClass('hidden');"
        page.insert_html :top, "stream_content",:partial => "streams/index", :locals => {:streams => [stream], :posted => true}
        page << "$('postPhoto').reset();$j('.shareServiceControl').hide();$j('#photoDescription').val('')"
        page.replace_html "uploadedPic", :text => "<div class='pathBar cornerAll'></div>"
        page << "notice('#{t :stream_posted}')"
      end
    else
      render :update do |page|
        page << "notice('#{t :attach_image}')"
      end
    end
  end

  def post_video
    asset = current_user.assets.find_by_id(params[:video_asset_id])
    if params[:file_path] && asset
      @unread_items = current_user.streams.unread_items.count
      @post = Post.new
      @post.save_message(params,current_user,7)
      user_service_list = []
      unless params[:post_group_user_service_id].blank?
        post_user_list = params[:post_group_user_service_id]*(",")
        user_service_list = params[:serviceid].to_a.concat(post_user_list.split(",")).uniq
      else
        user_service_list = params[:serviceid].to_a
      end
      stream = Stream.save_edintity_video_stream_details(params, current_user, user_service_list)
      stream.update_attributes(:video_status_id => Stream::VIDEO_STATUS["processing"])
      #      VideoUploadWorker.asynch_upload_to_services(:params => params, :user_service_list => user_service_list, :stream => stream.id, :user => current_user.id, :file_path => params[:file_path], :host => request.host_with_port)
      asset.update_attributes!({:attachable_id => stream.id, :attachable_type => "Stream"})
      unless params[:scope]
        services = current_user.user_services
      else
        brand = Brand.find_by_id(params[:brand_id])
        services = brand.brand_services
      end
      file = File.open(params[:file_path], "r")
      if user_service_list
        services.video_authorized.each do |service|
          if user_service_list.include?(service.id.to_s)
            url = "https://s3-eu-west-1.amazonaws.com/edintity/uploads/videos/#{asset.id}/#{asset['video_file_name']}"
            Post.post_video_to_service(params,service,file,url,stream,request.host_with_port)
          end
        end
        #        File.delete(params[:file_path])
      else
        #        File.delete(params[:file_path])
      end
      #      stream.update_attributes(:stream_created_at => Time.current, :video_status_id => Stream::VIDEO_STATUS["success"]) unless stream.blank?
      stream.update_attributes(:stream_created_at => Time.current)
      @upload_setting = UploadSetting.first
      render :update do |page|
        page << "jQuery('#videoPreview').addClass('hidden');"
        page.insert_html :top, "stream_content",:partial => "streams/index", :locals => {:streams => [stream], :posted => true}
        page << "$('postVideo').reset();$j('.shareServiceControl').hide();$j('#videoDescription').val('')"
        page.replace_html "uploadedVideo", :text => "<div class='pathBar cornerAll'></div>"
        page << "notice('#{t :stream_posted}')"
      end
    else
      render :update do |page|
        page << "notice('#{t :attach_video}')"
      end
    end
  end

  def swfupload_file(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    data
  end

  def upload
    original_filename = params['qqfile'].class == String ? params['qqfile'] : params['qqfile'].original_filename
    filename = "#{current_user.id}_#{Time.now.to_i}_#{original_filename.gsub(')','_').gsub('(','_')}"
    new_file = File.open('uploads/' + filename, "wb")
    str = params['qqfile'].class == String ? request.body.read : params['qqfile'].read
    new_file.write(str)
    new_file.close
    upload_file = File.open("uploads/#{filename}", "r")
    asset = current_user.assets.new({:asset => upload_file})
    asset.company_id = params[:company_id] unless params[:company_id].blank?
    asset.attachable_type = "Stream"
    if asset.save!
      @current_asset = asset
      #      image = render_to_string :partial => "home/uploaded_photos"

      image = @current_asset.asset.url.gsub("/s3.","/s3-eu-west-1.")#image[image.index("https"), 87]

      render :json => {:image => image, :asset_id => @current_asset.id}, :content_type => "text/html"
    else
      render :json => {:image => "Upload failed. Please try again"}, :content_type => "text/html"
    end
  end

  def upload_video
    original_filename = params['qqfile'].class == String ? params['qqfile'] : params['qqfile'].original_filename
    @file = "#{current_user.id}_#{Time.now.to_i}_#{original_filename.gsub(')','_').gsub('(','_')}"
    new_file = File.open('uploads/' + @file, "wb")
    str = params['qqfile'].class == String ? request.body.read : params['qqfile'].read
    new_file.write(str)
    new_file.close
    #    upload_file = File.open("uploads/#{filename}", "r")
    flv_video = Asset.convert_video(@file, current_user.id)
    file = flv_video[1]
    ext = File.extname(file.original_filename)
    unless file.blank?
      asset = current_user.assets.new({:video => file})
      if asset.save
        asset.update_attributes({:video_file_name => "originals#{ext}"})
        @file_path = flv_video[2]
        @current_asset = asset
        #        video = render_to_string :partial => "home/uploaded_video"
        render :json => {:video => @file_path, :asset_id => @current_asset.id, :video_file_name => @current_asset['video_file_name']}, :content_type => "text/html"
      end
    else
      render :json => {:image => "Upload failed. Please try again"}, :content_type => "text/html"
    end
  end

  def cancel_upload
    asset = current_user.assets.find_by_id(params[:id])
    asset.destroy if asset
    render :update do |page|
      if params[:type]
        page << "jQuery('#videoPreview').addClass('hidden');"
        page.replace_html "uploadedVideo", :text => "<div class='pathBar cornerAll'></div>"
      else
        page << "jQuery('#photoPreview').addClass('hidden');"
        page.replace_html "uploadedPic", :text => "<div class='pathBar cornerAll'></div>"
      end
    end
  end

  def get_services
    services = current_user.active_services.link_sharing_services
    service_ary = []
    services.each do |service|
      service_ary << "serviceid_" +service.id.to_s
    end
    services_array = []
    service_ary.each do |id|
      unless params[id].blank?
        services_array << params[id]
      end
    end

  end

  def add_tag(stream)
    begin
      @unread_items = current_user.streams.unread_items.count
      tags = params[:tag_name].split(",")
      if tags.size >= 5
        render :update do |page|
          page << "$('tag_div_#{params[:id]}').style.display='none';"
          page << "notice('#{t :tag_limit}')"
        end
      else
        tags.each do |tag|
          existing = current_user.tags.find_by_name(tag)
          unless existing.blank?
            stream.stream_tags.create(:tag_id => existing.id)
          else
            new = current_user.tags.create(:name => tag)
            stream.stream_tags.create(:tag_id => new.id)
          end
        end
        render :update do |page|
          page.replace_html "status_update",:partial => "posts/post_link"
          page.replace_html "unread_items_count", :partial => "streams/unread_items", :locals => {:current_user => current_user}
          page.insert_html :top, "stream_content",:partial => "streams/index", :locals => {:streams => [stream], :posted => true}
          page << "$j('.star').rating();"
          page << "$j('.auto-submit-star').rating();"
          page << "$('postForm').reset();"
          page << "notice('#{t :link_posted_with_tag}')"
        end
      end
    rescue
      render :update do |page|
        page << "notice('#{t :unable_to_create_tag}')"
      end
    end
  end

  def friends
    get_followings
    get_followers
    followings = @following_ids
    followers = @followers_ids
    friends = []
    friends =  (followings) & (followers)
    return friends
  end

  def get_followers
    my_followers = Follower.find_all_by_follower_id(current_user.id)
    @followers_ids = []
    my_followers.each do |follower|
      @followers_ids << follower.user_id
    end
    return @followers_ids
  end

  def get_followings
    my_followings = Follower.find_all_by_user_id(current_user.id)
    @following_ids = []
    my_followings.each do |following|
      @following_ids << following.follower_id
    end
    return @following_ids
  end
end
