class CustomStreamsController < ApplicationController

  before_filter :require_user

  def new
    @pick_types =  PostType.find(:all)
    @tags = current_user.tags.map.collect{|tag| tag.name}.join(",")
    @services = current_user.active_services
    @header = "#{t :create_custom_filter}"
    render :layout => 'redbox'
  end

  def create
    begin
      existing = current_user.custom_stream_filters.find_all_by_name(params[:name])
      if existing.blank?
        tags = params[:stream_tags].blank? ? "" : params[:stream_tags].to_a.join(",")
        posted_date = params["stream_posted_date"].blank? ? nil : Time.parse(params["stream_posted_date"])
        start_date = params["stream_start_date"].blank? ? nil : Time.parse(params["stream_start_date"])
        end_date = params["stream_end_date"].blank? ? nil : Time.parse(params["stream_end_date"])
        attributes = {:name => params[:name], :stream_posted_date => posted_date, :stream_start_date => start_date, :stream_end_date => end_date, :stream_tags => tags, :user_service_ids => params[:serviceid].blank? ? "" : params[:serviceid].join(",")}
        new_filter = current_user.custom_stream_filters.create(attributes)
        if params[:apply_filter] == "1"
          params[:custom_id] = new_filter ? new_filter.id : nil
          apply_filter(true)
        else
          render :update do |page|
            page << "notice('#{t :custom_stream_saved}')"
            page.replace_html "saved_filters", :partial => "show"
            page << "$j('#filter_count').html(#{current_user.custom_stream_filters.count})"
            page << "RedBox.close();"
          end
        end
      else
        render :update do |page|
          page << "notice('custom stream with name [#{params[:name]}] already exists. please give another name')"
        end
      end
    rescue Exception => e
      render :update do |page|
        page << "notice('#{t :custom_stream_not_saved}')"
      end
    end
  end

  def edit
    @pick_types =  PostType.find(:all)
    @custom_stream = current_user.custom_stream_filters.find_by_id(params[:custom_id])
    @tags = current_user.tags.map.collect{|tag| tag.name}.join(",")
    @filter_tags = @custom_stream.stream_tags
    @services = current_user.active_services
    @header = "#{t :edit_custom_filter}"
    render :layout => 'redbox'
  end

  def update
    begin
      existing = current_user.custom_stream_filters.find_all_by_name(params[:name], :conditions => ["id != ?", params[:custom_id]])
      if existing.blank?
        posted_date = params["stream_posted_date"].blank? ? nil : Time.parse(params["stream_posted_date"])
        start_date = params["stream_start_date"].blank? ? "" : Time.parse(params["stream_start_date"])
        end_date = params["stream_end_date"].blank? ? "" : Time.parse(params["stream_end_date"])
        tags = params[:stream_tags].blank? ? "" : params[:stream_tags].to_a.join(",")
        custom_stream = current_user.custom_stream_filters.find_by_id(params[:custom_id])
        attributes = {:name => params[:name], :stream_posted_date => posted_date, :stream_start_date => start_date, :stream_end_date => end_date, :stream_tags => tags, :user_service_ids => params[:serviceid].blank? ? "" : params[:serviceid].join(",")}
     
        custom_stream.update_attributes(attributes)
        if params[:apply_filter] == "1"
          apply_filter(true)
        else
          render :update do |page|
            page << "notice('#{t :custom_stream_updated}')"
            page.replace_html "saved_filters", :partial => "show"
            page << "RedBox.close();"
          end
        end
      else
        render :update do |page|
          page << "notice('custom stream with name [#{params[:name]}] already exists. please give another name')"
        end
      end
    rescue Exception => e
      render :update do |page|
        page << "notice('#{t :custom_stream_not_updated}')"
      end
    end
  end

  def delete
    begin
      custom_stream = current_user.custom_stream_filters.find_by_id(params[:custom_id])
      custom_stream.destroy if custom_stream
      render :update do |page|
        page << "RedBox.close();"
        page << "$j('#filter_count').html(#{current_user.custom_stream_filters.count})"
        page.replace_html "saved_filters", :partial => "show"
        page << "notice('#{t :custom_stream_deleted}')"
      end
    rescue Exception => e
      render :update do |page|
        page << "RedBox.close();"
        page << "notice('#{t :custom_stream_not_deleted}')"
      end
    end
  end

  def delete_confirm
    @custom_stream_id = params[:custom_id]
    @header = ""
    render :layout => 'redbox'
  end

  def load_service_list
    type =  PostType.find_by_id(params[:type])
    @post_service_group = current_user.post_service_groups.find_by_id(params[:id])
    get_services(type) if type
    render :update do |page|
      page.replace_html 'service_list', :partial => "services_list"
      page << "$j('#service_list').show();"
    end
  end

  def get_services(type)
    if type.name == "Photo"
      @services = current_user.active_services.photo_sharing_services
      @service_type = "photo sharing"
    elsif type.name == "Link"
      @services = current_user.active_services.link_sharing_services
      @service_type = "link sharing"
    elsif type.name == "Blog"
      @services = current_user.active_services.blog_sharing_services
      @service_type = "blog sharing"
    elsif type.name == "Status Update"
      @services = current_user.active_services.link_sharing_services
      @service_type = "status update sharing"
    else
      @services = nil
    end
  end

  def apply_filter(create_or_update=false)
    get_streams
    render :update do |page|
      if create_or_update
        page << "notice('#{t :custom_stream_saved_and_filtered}')"
        page.replace_html "saved_filters", :partial => "show"
        page << "$j('#filter_count').html(#{current_user.custom_stream_filters.count})"
        page << "RedBox.close();"
      end
      page << "$j('#stream_notify').hide();"
      page << "$j('.top_menu').hide();"
      page << "$j('.stream.rounded').hide();"
      page << "$j('.play').hide();"
      page << "$j('#unread_items_count').hide();"
      page << "$j('.no_users').hide();"
      page << "$j('.find_friends').hide();"
      page << "$j('.content_div').hide();"
      page << "$j('.users_list').hide();"
      page << "$j('#tabs_user').hide();"
      page << "$j('.posttype').hide();"
      page << "$j('.new_item_bar_div').hide();"
      page.replace_html "stream_content", :partial => "streams/index", :locals => {:custom => true}
      page.insert_html :top, 'stream_content', :partial => "custom_streams_header", :locals => {:params => params} if @custom_stream
      page << "$j('#stream_content').show();"
    end
  end

  def rss
    get_streams    
    render :layout => false
  end

  def get_streams
    @current_user = current_user || User.find_by_user_name(params[:user_name])
    @custom_stream = @current_user ? @current_user.custom_stream_filters.find_by_id(params[:custom_id]) : nil
    unless @custom_stream.blank?
      @streams = CustomStreamFilter.get_streams(@custom_stream, @current_user)
    else
      @streams = []
    end
  end
  
end
