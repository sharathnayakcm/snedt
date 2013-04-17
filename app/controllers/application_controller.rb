# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user

  before_filter :set_user_time_zone
  before_filter :set_locale

  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  #  rescue_from Exception do |exception|
  #    if Rails.env == "production"
  #      logger.error "Error: #{exception.to_s}. Backtrace: #{exception.backtrace}"
  ##      @email = ActionMailer::Base.deliveries
  ##      @email.clear
  ##      @email = Notifier.deliver_error_message(exception, session, params, request)
  #      if exception.class == 'ActionController::InvalidAuthenticityToken'
  #        reset_session
  #        flash[:notice] = "Oops, there was an error with your earlier session. Please try to login again."
  #        redirect_to root_path
  #        return
  #      elsif exception.class == 'ActionController::RoutingError'
  #        flash[:notice] = "<p style='color:red;'>Page not found.</p>"
  #        redirect_back_or_default root_path
  #      else
  #        flash[:notice] = "<p style='color:red;'>We are sorry something went wrong. Please try again later.</p>"
  #        redirect_back_or_default root_path
  #      end
  #    else
  #      logger.error "Error: #{exception.to_s}. Backtrace: #{exception.backtrace}"
  #      render :text => exception.message
  #    end
  #  end

    def get_more_streams(params,current_user)
    @stream_actions = current_user.read_or_create_stream_actions
    if params[:search_filter]
      get_search_streams
      @streams = @streams.paginate(:per_page => 1, :page => params[:current_page])
    elsif params[:filter]
      #TODO: Move all the queries to model
      if params[:by]
        if params[:by] == "all"
          @streams = current_user.streams.displayed.paginate(:page => params[:current_page], :per_page => 25)
        elsif params[:by] == "read"
          @streams = current_user.streams.read_items.paginate(:page => params[:current_page], :per_page => 25)
        elsif params[:by] == "unread"
          @streams = current_user.streams.unread_items.paginate(:page => params[:current_page], :per_page => 25)
        elsif params[:by] == "favourites"
          @streams = current_user.favourites.paginate(:page => params[:current_page], :per_page => 25)
        end
      else
        @streams = current_user.streams.displayed.find(:all, :conditions => "service_id = #{params[:service_id]}").paginate(:page => params[:current_page], :per_page => 25)
      end
    else
      if params[:tab_name]
        @stream_header = params[:tab_name]
        @streams = current_user.send("#{params[:tab_name]}_streams").paginate(:page => params[:current_page], :per_page => 25)
      else
        @streams = current_user.streams.displayed.paginate(:page => params[:current_page], :per_page => 25)
      end
    end
  end


  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  def set_user_time_zone
    #    raise current_user.time_zone.inspect
    Time.zone = current_user.time_zone if current_user
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
    @current_user = @current_user.blank? ? @current_user : User.find(@current_user.id, :include => [:followers, :followings, :privacy_groups, :post_service_groups, :brand_user_groups])
  end

  def current_company
    @current_company = current_user.company if current_user
  end
  def require_user
    unless current_user
      store_location
      flash[:notice] = "#{t :require_login}"
      redirect_to login_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      redirect_to root_url
      return false
    end
  end

  def admin_required
    if current_user
      unless current_user.is_admin?
        flash[:notice] = "You are not allowed to access this page"
        redirect_to root_path
      else
        return true
      end
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def sign_up
    @sign_up  = "true"
    return @sign_up
  end

  def set_locale
    if params[:locale]
      if params[:locale] != "en" && params[:locale] != "arabic"
        params[:locale] = "en"
      end
      session[:locale] = params[:locale]
    elsif current_user
      session[:locale] = current_user.prefered_language if session[:locale].blank?
    end
    locale = session[:locale] || 'en'
    I18n.locale = locale
    I18n.load_path += Dir[ File.join(RAILS_ROOT, 'lib', 'locale', '*.{yml}') ]
  end

  def active_company
    if current_user.company && !current_user.company.active
      notice = "#{t :company_inactive}"
      respond_to do |format|
        format.html {
          flash[:notice] = notice
          redirect_to(company_url(current_user.company.name))
        }
        format.js {
          render :update do |page|
            page << "notice(#{notice})"
            page.redirect_to company_url(current_user.company.name)
          end
        }
      end
    end
  end


  def user_name_filter(user_name)
    unless user_name.blank?
      return true unless BLOCKED_USER_NAMES.index(user_name.downcase).blank?
      blocked_user_names = BLOCKED_USER_NAMES.join("-")
      user_name_length = user_name.length.to_i
      (4..user_name_length).each_with_index do |user_name_index, idx|
        unless blocked_user_names.index(user_name.downcase[0, user_name_index.to_i]).blank?
          return true
        end
        unless blocked_user_names.index(user_name.downcase[idx, (idx == 0 ? 1 : idx)+3]).blank?
          return true
        end
      end

      return false
    end
  end

  private
  def can_view_profile(user, profile_user)
    unless user.blank?
      blocked = BlockedUser.find_by_user_id_and_blocked_user_id( profile_user.id,user.id)
      return !(blocked.blank?)? false : true
    else
      return true
    end
  end

  def get_rss_feeds(user)
    streams = []
    @unread_items = 0
    user.rss_links.each do |link|
      streams += link.streams.displayed_rss
      @unread_items += link.streams.unread_items_rss.count
    end
    @rss_streams = streams.paginate(:page => 1, :per_page => 10)
  end

end

