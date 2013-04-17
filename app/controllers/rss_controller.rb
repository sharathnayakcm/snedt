class RssController < ApplicationController
  require 'feedzirra'
  before_filter :require_user
  
  def show
    @current_user = current_user
    @current_user.update_attributes(:status => "5")
    @user_tabs = current_user.active_tabs
    @user_unused_tabs = current_user.unused_tabs
    @privacy_group_count = current_user.privacy_groups.count
    @stream_actions = current_user.read_or_create_stream_actions
    RssLink.get_feeds(current_user)
    get_rss_feeds
    @show_popup = current_user.preferences.find_all_by_preference_id(1).length == 0
    @controller_name = "rss"
    @tab_name = "rss_reader"
    @services = Service.find(:all)
  end

  def add_link
    @header = "#{t :add_rss}"
    @rss_add_link = true
    render :layout => 'redbox'
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

  def delete_link
    links = current_user.rss_links.find(:all ,:conditions => ["id in (#{params[:id]})"])
    if links
      links.each do |link|
        link.destroy 
      end
    end
    get_rss_feeds
    render :update do |page|
      page << "$('button_to_close').click();"
      page.replace_html 'stream_content', :partial => "streams/index", :locals => {:streams => @streams}
#      page.replace_html 'unread_items_count', :partial => "streams/unread_items", :locals => {:unread_items => @unread_items}
      page << "notice('#{t :feed_url_deleted}')"
    end
  end

  def rename_link
    link = current_user.rss_links.find(params[:id])
    link.update_attribute('title', params[:title]) if link
    render :update do |page|
      page << "notice('#{t :feed_url_renamed}')"
      page.replace_html 'link_list',:partial => "rss/feed_links", :locals => {:links => current_user.rss_links}
    end
  end

  def is_url_valid?
    @rss = Feedzirra::Feed.fetch_and_parse(params[:rss_link])
  end

  def close_link_window
    if params[:rss_new_link_added] == "true"
      RssLink.get_feeds(current_user)
      get_rss_feeds
      render :update do |page|
        page << "$('button_to_close').click();"
        page.replace_html 'stream_content', :partial => "streams/index", :locals => {:streams => @streams}
#        page.replace_html 'unread_items_count', :partial => "streams/unread_items", :locals => {:unread_items => @unread_items}
      end
    else
      render :update do |page|
        page << "$('button_to_close').click();"
      end
    end
  end

  def save_link
    begin
      params[:rss_link] = params[:rss_link].gsub("^equal_to^", "=")
      params[:rss_link] = params[:rss_link].gsub("^question_mark^", "?")
      params[:rss_link] = params[:rss_link].gsub("^and^", "&")
      already_added = current_user.rss_links.find_by_url(params[:rss_link])
      if already_added
        render :update do |page|
          page << "notice('#{t :duplicate_url}')"
        end
      else
        valid_rss = params[:results] ? true : is_url_valid?
        if valid_rss
          title = params[:results] ? params[:rss_title] : @rss.title
          RssLink.create(:user_id => current_user.id,:title => title, :url => params[:rss_link])
          render :update do |page|
            page << "$('rssLink').reset();"
            page << "$('#{params[:rss_link]}').remove();" if params[:rss_title]
            page << "$('rss_new_link_added').value = true;"
            page << "notice('#{t :feed_url_added}')"
          end
        else
          render :update do |page|
            page << "notice('#{t :feed_url_invalid}')"
          end
        end
      end
    rescue Exception => e
      render :update do |page|
        page << "notice('#{t :feed_url_invalid}')"
      end
    end
  end

  def manage_rss
    if params[:confirm_delete]
      @confirm_delete = true
      @id = params[:id].chop()
      @link_names = ""
      links = current_user.rss_links.find(:all ,:conditions => ["id in (#{@id})"])
      if links
        links.each do |link|
          @link_names += " " + link.title + " ,"
        end
      end
      @link_names = @link_names.chop()
    else
      @links = current_user.rss_links
      @header = "#{t :manage_rss}"
    end
    render :layout => 'redbox'
  end

  def more_streams
    streams = []
    @stream_count = 0
    current_user.rss_links.each do |link|
      streams += link.streams.displayed_rss
      @stream_count += link.streams.not_displayed_rss.count
    end
    @streams = streams.sort {|x,y| y.stream_created_at <=> x.stream_created_at }.paginate(:page => params[:current_page], :per_page => 25)
    @stream_actions = current_user.read_or_create_stream_actions
    @show_popup = current_user.preferences.find_all_by_preference_id(1).length == 0
    render :update do |page|
      page.insert_html :bottom, 'stream_content', :partial => "streams/more_streams", :locals => {:streams => @streams, :current_page => params[:current_page].to_i}
      page << "$j('.auto-submit-star').rating();"
    end
  end

  def filter_streams
     RssLink.get_feeds(current_user)
    get_rss_feeds
    @custom_tab = current_user.custom_tabs.find_by_id(params[:id])
#    @streams = current_user.friends_streams
    @filter = true
    @by = params[:by]
    @service_id = params[:service_id]
    @stream_actions = current_user.read_or_create_stream_actions
    if params[:by]
      if params[:by] == "all"
        @streams = @streams.paginate(:per_page => 25, :page => params[:page] || 1)
      elsif params[:by] == "read"
        read_streams = @streams.select {|x| (x.is_read == true and x.is_deleted == nil) and x.message_type_id == 8 }
        @streams = read_streams.paginate(:per_page => 25, :page => params[:page] || 1)
      elsif params[:by] == "unread"
        unread_streams = @streams.select {|x| (x.is_read == false and x.is_deleted == nil) and x.message_type_id == 8 }
        @streams = unread_streams.paginate(:per_page => 25, :page => params[:page] || 1)
      elsif params[:by] == "favourites"
        favourites = @streams & current_user.favourites
        @streams = favourites.paginate(:per_page => 25, :page => params[:page] || 1)
      end
    else
      service_streams = @streams.select {|x| (x.service_id == params[:service_id].to_i and x.is_deleted == nil) and x.message_type_id != 8 }
      @streams = service_streams.paginate(:per_page => 25, :page => params[:page] || 1)
    end
    render :update do |page|
      page.replace_html "stream_content", :partial => "streams/index"
      page << "$j('#stream_content').show();"
    end
  end


end
