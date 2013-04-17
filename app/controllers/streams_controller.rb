class StreamsController < ApplicationController
  layout "application"
  before_filter :require_user
  before_filter :load_stream, :only => [:update_rating, :toggle_favourite, :mark_as_favourite]
  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  def new
    @stream = Stream.new
  end

  def create

    if Stream.save_and_share_to_services(params, current_user)
      redirect_to my_streams_path
    else
      render :new
    end
  end

  def upgrade_member_video
    @header = "upgrade member"
    render :layout => "redbox"
  end

  def update_stream_topic
    @stream = Stream.find_by_id(params[:id])
    @topic = Topic.find_by_id(params[:topic_id])
    @stream.update_attribute(:topic_id, params[:topic_id])
    render :update do |page|
      page << "$j('#sharingtopic_#{params[:id]}').hide();"
      page << "$j('#social_topics_#{params[:id]}').hide();"
      page << "$j('#social_inbox_topics_#{params[:id]}').html(\"<a style='font-weight:bold;'>#{current_user.full_name}</a> added to topic <a style='font-weight:bold;'>#{@topic.title}</a> \")"
      page << "notice('#{t :added_topic_sucessfully}')"
    end

  end
  
  def get_topics
    #respond_with(Topic.find(:all, :select => 'title').map{|t| t.title})
    respond_to do |format|
      format.js { render :json => Topic.find(:all).map{|t| {:id => t.id, :value => t.title}}.to_json }
    end
  end
  
  def get_stream_from_db
    if params[:controller_name] == "rss"
      streams = []
      current_user.rss_links.each do |link|
        streams += link.streams.not_displayed_rss
      end
    else
      unless params[:brand_id].blank?
        begin
          brand = Brand.find_by_id(params[:brand_id])
          streams = brand.streams.not_displayed_for_brands
        rescue
        end
      else
        streams = current_user.streams.not_displayed
      end
    end
    render :update do |page|
      streams.each do |stream|
        page.insert_html :top, "stream_content", :partial => "streams/show", :locals => {:stream => stream}
        stream.update_attribute(:is_displayed, true)
      end
      #      page.replace_html "stream_count_message_span", "#{t :play_stream, :count => 0}"
      #      page << "$j('.auto-submit-star').rating();"
      #      page << "$j('.no_results').hide()" unless streams.blank?
      page << "$j('#stream_count').html(0)"
      page << "notice('#{t :streamed} - #{streams.size} #{t :streams}')"
    end
  end

  def add_thankyou
    ThankYou.create(:stream_id=>params[:id],:user_id => current_user.id)
    render :update do |page|
      page << "$j('#thankyou_#{params[:id]}').html('Sent Thankyou');"
      page << "notice('#{t :success_thank_you}')"
    end
  end

  def toggle_favourite
    @stream.toggle!(:is_favourite)
    if @stream.is_favourite
      render :update do |page|
        page.replace_html "love_#{@stream.id}", "#{image_tag('favourite_heart.png')}"
        page << "notice('#{t :stream_marked_favourite}')"
      end
    else
      render :update do |page|
        page.replace_html "love_#{@stream.id}", "#{image_tag('love.png')}"
        page << "notice('#{t :stream_unfavourite_successful}')"
      end
    end
  end

  def mark_as_favourite
    pos_notice = params[:social_inbox] == "false" ? (t :mark_favorite) : (t :stream_Bookmarked)
    neg_notice = params[:social_inbox] == "false" ? (t :mark_unfavorite) : (t :stream_UnBookmarked)
    pos_text = params[:social_inbox] == "false" ? "Unfavorite" : "UnBookmark"
    neg_text = params[:social_inbox] == "false" ? "Favorite" : "Bookmark"
    mark_as_favourite = current_user.favourite_streams.find_by_stream_id(params[:id])
    if mark_as_favourite.blank?
      current_user.favourite_streams.create(:stream_id => params[:id])
      stream = Stream.find_by_id(params[:id])
      fav_count = stream.favourite_streams.count
      if stream && stream.stream_id.present?
        Activity.add_points(current_user, Activity::ACTIVITY_TYPES[:favorite], 'Stream', stream.id, stream.user_id)
        Activity.add_points(stream.user, Activity::ACTIVITY_TYPES[:favorited], 'Stream', stream.id, current_user.id) unless current_user == stream.user
      end
      render :update do |page|
        page << "notice('#{pos_notice}')"
        page << "$j('#fav_#{params[:id]}').text('#{fav_count} #{pos_text}');"
        page << "$j('#fav_#{params[:id]}').removeClass('fav');$j('#fav_#{params[:id]}').addClass('favTrue');"
      end
    else
      mark_as_favourite.destroy
      render :update do |page|
        page << "notice('#{neg_notice}')"
        page << "$j('#fav_#{params[:id]}').text('#{fav_count} #{neg_text}');"
        page << "$j('#fav_#{params[:id]}').removeClass('favTrue');$j('#fav_#{params[:id]}').addClass('fav');"
      end
    end
  end

  def delete_stream(popup=false)
    popup = params[:popup].to_i if params[:popup]
    if params[:do_not_show]
      current_user.preferences.create(:preference_id => 1)
    end
    stream = Stream.find(params[:id])
    stream.update_attribute(:is_deleted, true)
    render :update do |page|
      if popup || popup == "true"
        page << "RedBox.close();"
      end
      if params[:do_not_show]
        page << "$('RB_redbox').style.display = 'none';"
      end
      page << "Effect.Fade('stream_content_#{stream.id}')"
      page << "notice('#{t :stream_deleted}')"
      page << "$j('object').show();"
    end
  end

  def delete_stream_confirm
    if current_user.preferences.find_all_by_preference_id(1).length == 0
      @stream_id = params[:id]
      @header = "#{t :delete_stream_header}"
      render :layout => 'redbox'
    else
      delete_stream(true)
    end
  end

  def flag_video_confirm
    @stream_id = params[:id]
    @header = "#{t :flag_video_header}"
    render :layout => 'redbox'
  end

  def flag_video
    already_flagged = FlaggedVideo.find_by_stream_id_and_reporter_id(params[:id], current_user.id)
    if already_flagged.blank?
      FlaggedVideo.create({:stream_id => params[:id], :reporter_id => current_user.id, :description => params[:flag]})
    end
    render :update do |page|
      page << "notice('#{t :stream_flagged}')"
      page << "$j('embed').show();"
      page << "RedBox.close();"
    end
  end

  def update_rating
    @stream.update_attribute(:star_count, @stream.star_count.to_i + params[:count].to_i)
    render :update do |page|
      page.replace_html "stream_rating_#{@stream.id}", :partial => "shared/stars", :locals => {:stream => @stream}
    end
  end

  def shorten_link
    if params[:long_url].blank?
      render :update do |page|
        page << "notice('#{t :enter_long_url}')"
      end
    else
      long_url = params[:long_url].strip
      if long_url.match(/^www([.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&amp;\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)/)
        long_url = "http://#{long_url}"
      end
      short_url, error_message = shorten_with_bitly(long_url)
      render :update do |page|
        if error_message.blank?
          page << "$('status_update_message').value = $('status_update_message').value + '#{short_url}'"
          page << "$('long_url').value = '';"
          page << "char_count_up();toggle_visibility('shortURL');"
        else
          page << "notice('#{error_message}')"
        end
      end
    end
  end

  # has to change this using link_to_remote function
  def toggle_read
    # RSS
    @unread_items = 0
    if params[:controller_name] == "rss"
      @controller_name = "rss"
      current_user.rss_links.each do |link|
        @unread_items += link.streams.unread_items_rss.count
      end
    else
      @unread_items = current_user.streams.unread_items.count
    end
    # Toggle Read

    @stream = Stream.find_by_id(params[:id])
    @stream.toggle!(:is_read)
    @streams_count = current_user.streams.displayed
    if @stream.is_read
      @unread_items -= 1
      render :update do |page|
        page << "$j('#read_#{@stream.id}').removeClass('markUnread');$j('#read_#{@stream.id}').addClass('markRead');"
        page << "notice('#{t :stream_marked_read}')"
        #        page.replace_html "unread_items_count", :partial => "streams/unread_items", :locals => {:current_user => current_user}
      end
    else
      @unread_items += 1
      render :update do |page|
        page << "$j('#read_#{@stream.id}').removeClass('markRead');$j('#read_#{@stream.id}').addClass('markUnread');"
        page << "notice('#{t :stream_marked_unread}')"
        #        page.replace_html "unread_items_count", :partial => "streams/unread_items", :locals => {:current_user => current_user}
      end
    end

  end

  def mark_all_read
    if params[:controller_name] == "rss"
      current_user.rss_links.each do |link|
        Stream.update_all({:is_read => true}, {:id => link.streams.unread_items_rss})
      end
      @controller_name = "rss"
      get_rss_feeds
      render :update do |page|
        page.replace_html "stream_content", :partial => "streams/index"
        page << "notice('#{t :marked_all_as_read}')"
        page.replace_html "unread_items_count", :partial => "streams/unread_items", :locals => {:current_user => current_user}
      end
    else
      partial_path = "streams/unread_items"
      unless params[:brand_id].blank?
        partial_path = "streams/brands/unread_items"
        brand = Brand.find(params[:brand_id])
        @brand = brand
        brand = brand.company if brand.is_default?
        Stream.update_all({:is_read => true}, {:brand_id => brand.streams.unread_items})
        @streams = brand.streams.displayed_for_brand
      else
        Stream.update_all({:is_read => true}, {:id => current_user.streams.unread_items})
        @streams = current_user.streams.displayed
      end
      render :update do |page|
        page.replace_html "stream_content", :partial => "streams/index"
        page << "notice('#{t :marked_all_as_read}')"
        #        page.replace_html "unread_items_count", :partial => partial_path, :locals => {:current_user => current_user}
      end
    end
  end

  def mark_all_unread
    if params[:controller_name] == "rss"
      @controller_name = "rss"
      current_user.rss_links.each do |link|
        links = link.streams.read_items_rss
        Stream.update_all({:is_read => false}, {:id => links})
      end
      get_rss_feeds
      render :update do |page|
        page.replace_html "stream_content", :partial => "streams/index"
        page << "notice('#{t :stream_marked_unread}')"
        page.replace_html "unread_items_count", :partial => "streams/unread_items", :locals => {:current_user => current_user}
      end
    else
      partial_path = "streams/unread_items"
      unless params[:brand_id].blank?
        partial_path = "streams/brands/unread_items"
        brand = Brand.find(params[:brand_id])
        @brand = brand
        brand = brand.company if brand.is_default?
        Stream.update_all({:is_read => false}, {:brand_id => brand.streams.unread_items})
        @streams = brand.streams.displayed_for_brand
        @unread_items = brand.streams.unread_items.count
      else
        Stream.update_all({:is_read => false}, {:id => current_user.streams.read_items})
        @streams = current_user.streams.displayed
        @unread_items = current_user.streams.unread_items.count
      end
      render :update do |page|
        page.replace_html "stream_content", :partial => "streams/index"
        page << "notice('#{t :stream_marked_unread}')"
        #        page.replace_html "unread_items_count", :partial => partial_path, :locals => {:current_user => current_user}
      end
    end
  end

  def get_rss_feeds
    streams = []
    @unread_items = 0
    current_user.rss_links.each do |link|
      streams += link.streams.displayed_rss
      @unread_items += link.streams.unread_items_rss.count
    end
    @streams = streams.sort {|x,y| y.stream_created_at <=> x.stream_created_at }.paginate(:page => 1, :per_page => 25)
  end

  def show_full_image
    @stream = Stream.find(params[:id])
    render :layout => 'redbox'
  end

  def retweet
    begin
      stream = Stream.find_by_id(params[:id])
      #message = "RT @#{stream.sender.user_name}: " +stream.text
      #options = {:title => truncate(message, :length => 140), :stream_id => stream.stream_id}
      options = {"stream" => stream}
      unless params[:user_service_ids].blank?
        profile_retweet = true
        params[:user_service_ids].each do |id|
          Post.post_to_twitter(options,current_user,id,true)
        end
      end
      streams = current_user.streams.not_displayed.find(:all, :conditions => "retweeted = true")
      render :update do |page|
        unless profile_retweet
          streams.each do |new_stream|
            page.insert_html :top, "stream_content", :partial => "streams/show", :locals => {:stream => new_stream}
            stream.update_attribute(:is_displayed, true)
          end
        end
        #page << "$('retweet_spinner_#{stream.id}').hide();"
        #page << "$j('.auto-submit-star').rating();"
        page.replace_html "retweet_#{stream.id}", link_to('' , 'javascript: void(0);', :class => 'retweeted')
        page << "notice('Stream retweeted successfully')"
        #page << "RedBox.close();"
      end
    end
  rescue Exception => e
    puts e.inspect
    render :update do |page|
      page << "notice('Stream retweet failed')"
      #page << "RedBox.close();"
    end
  end
=begin
  def retweet
    begin
      stream = Stream.find_by_id(params[:id])
      message = "RT @#{stream.sender.user_name}: " +stream.text
      options = {:title => truncate(message, :length => 140)}
      unless params[:user_service_ids].blank?
        profile_retweet = true
        params[:user_service_ids].each do |id|
          Post.post_to_twitter(options,current_user,id,true)
        end
      end
      streams = current_user.streams.not_displayed.find(:all, :conditions => "retweeted = true")
      render :update do |page|
        unless profile_retweet
          streams.each do |new_stream|
            page.insert_html :top, "stream_content", :partial => "streams/show", :locals => {:stream => new_stream}
            stream.update_attribute(:is_displayed, true)
          end
        end
        page << "$('retweet_spinner_#{stream.id}').hide();"
        page << "$j('.auto-submit-star').rating();"
        page << "notice('Stream retweeted successfully')"
        page << "RedBox.close();"
      end
    end
  rescue Exception => e
    render :update do |page|
      page << "notice('Stream retweet failed')"
      page << "RedBox.close();"
    end
  end
=end
  def stream_settings
    @stream = current_user.streams.find(params[:id])
    @setting_for = params[:setting_for]
    @header = "#{t :stream_settings_header}"
    render :layout => 'redbox'
  end

  def retweet_select_services
    @stream = Stream.find_by_id(params[:id])
    @header = "#{t :retweet_select_services}"
    render :layout => 'redbox'
  end

  def save_stream_settings
    stream = current_user.streams.find(params[:id])
    if params[:setting_for] == "comment"
      disallow_comments = params[:disallow_comments] ? true : false
      stream.update_attribute(:disallow_comments, disallow_comments)
    else
      disallow_retweet = params[:disallow_retweet] ? true : false
      stream.update_attribute(:disallow_retweet, disallow_retweet)
    end
    render :update do |page|
      page << "notice('#{t :stream_settings_saved}')"
      page << "RedBox.close();"
    end
  end

  def report_abuse
    @stream = Stream.find_by_id(params[:id])
    @header = "Report As Abuse"
    render :layout => "redbox"
  end

  def report_abuse_admin
    @stream = Stream.find_by_id(params[:id])
    @abuse_comment = AbuseContent.create(:user_id => current_user.id, :stream_id => @stream.id, :user_comments => params[:abuse_content_description], :reason => params[:abuse][:reason])
    @stream.report_abuse = 1
    @stream.abuse_reporter_id = current_user.id
    render :update do|page|
      if @stream.save
        @admin_users = User.find(:all, :conditions =>['is_admin = true'])
        @admin_users.each do |admin|
          Notification.deliver_notification("Report Admin",admin, { "params" => {"stream_id" => @stream.id}}, :locale => session[:locale] == "arabic")
        end
        page << "Effect.Fade('stream_content_#{@stream.id}')"
        page << "RedBox.close();"
        page << "notice('#{t :stream_abuse_report}')"

      else
        page << "notice('#{t :stream_abuse_report_fail}')"
      end
    end
  end

  def add_view_count
    stream = Stream.find_by_id(params[:id])
    if stream
      stream.update_attributes({:view_count => stream.view_count + 1})
      current_user.stream_views.create(:stream_id => stream.id)
      render :update do|page|

      end
    end
  end

  def facebook_comments
    stream = Stream.find_by_id(params[:id])
    if stream && stream.user_service
      comments = UserSession.get_facebook_comments(stream, stream.user_service)
      render :update do |page|
        page << "$j('#fb_comment_spinner_#{stream.id}').addClass('hide')"
        page.replace_html "stream_fb_comments_#{stream.id}", :partial => "comments/facebook_comments", :locals => {:stream => stream, :comments => comments}
      end
    else
      render :nothing => true
    end
  end

  def twitter_comments
    stream = Stream.find_by_id(params[:id])
    if stream && stream.user_service
      comments = stream.get_twitter_replies
      render :update do |page|
        page << "$j('#twitter_comment_spinner_#{stream.id}').addClass('hide')"
        page.replace_html "stream_twitter_comments_#{stream.id}", :partial => "comments/twitter_comments", :locals => {:stream => stream, :comments => comments}
      end
    else
      render :nothing => true
    end
  end

  def share_stream
    stream = Stream.find params[:stream_id]
    share = {"stream_post_type" => 'status', "status_update_message" => stream.text, "stream" => stream}
    Post.post_to_services(stream, share,current_user,params[:serviceid],false)
    Activity.add_points(current_user, Activity::ACTIVITY_TYPES[:share], 'Stream', stream.id, stream.user_id)
    Activity.add_points(stream.user, Activity::ACTIVITY_TYPES[:shared], 'Stream', stream.id, current_user.id) unless current_user == stream.user
    render :update do |page|
      page << "notice('Stream shared successfully')"
    end
  end

  private
  def load_stream
    @stream = Stream.find(params[:id])
  end

  def get_feeds_from_services
    @messages_hash, errors = UserSession.get_twitter_messages(current_user) if current_user.has_twitter_service
    #TODO: Move all the queries to model
    UserSession.get_flickr_messages(current_user) if current_user.has_flickr_service
    UserSession.get_facebook_messages(current_user) if current_user.has_facebook_service
    UserSession.get_facebook_page_messages(current_user) if current_user.has_facebook_page
    UserSession.get_vimeo_videos(current_user) if current_user.has_vimeo_service
    UserSession.get_youtube_videos(current_user) if current_user.has_youtube_service
    UserSession.get_tumblr_messages(current_user) if current_user.has_tumblr_service
    UserSession.get_delicious_messages(current_user) if current_user.has_delicious_service
    UserSession.get_stumbleupon_messages(current_user) if current_user.has_stumbleupon_service
    return errors
  end


  #TODO Code to be reviewed
  def get_company_feeds_from_services(brand)
    @messages_hash, errors = UserSession.get_twitter_messages(brand) if brand.has_twitter_service
    #TODO: Move all the queries to model
    UserSession.get_flickr_messages(brand) if brand.has_flickr_service
    UserSession.get_facebook_messages(brand) if brand.has_facebook_service
    UserSession.get_vimeo_videos(brand) if brand.has_vimeo_service
    UserSession.get_youtube_videos(brand) if brand.has_youtube_service
    UserSession.get_tumblr_messages(brand) if brand.has_tumblr_service
    UserSession.get_delicious_messages(brand) if brand.has_delicious_service
    UserSession.get_stumbleupon_messages(brand) if brand.has_stumbleupon_service
    return errors
  end  

end
