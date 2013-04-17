class Admin::AdminRssLinksController < ApplicationController
#  require 'feedzirra'
  before_filter :require_user
  before_filter :admin_required
  
  def index
    load_notifications
  end

  def new
    @header = "#{t :add_rss}"
    render :layout => 'redbox'
  end

  def create
    begin
      params[:rss_link] = params[:rss_link].gsub("^equal_to^", "=")
      params[:rss_link] = params[:rss_link].gsub("^question_mark^", "?")
      params[:rss_link] = params[:rss_link].gsub("^and^", "&")
      already_added = current_user.admin_rss_links.find_by_url(params[:rss_link])
      if already_added
        render :update do |page|
          page << "notice('#{t :duplicate_url}')"
        end
      else
        valid_rss = params[:results] ? true : is_url_valid?
        if valid_rss
          title = params[:results] ? params[:rss_title] : @rss.title
          current_user.admin_rss_links.create(:title => title, :url => params[:rss_link], :status => true)
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

  def is_url_valid?
    @rss = Feedzirra::Feed.fetch_and_parse(params[:rss_link])
  end

  def destroy
    link = AdminRssLink.find(params[:id])
    if link.destroy
      render :update do |page|
        page << "Effect.Fade('admin_rss_link_#{link.id}')"
        page << "notice('RSS link deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete RSS Link, please try again!')"
      end
    end
  end
#  def delete_link
#    links = current_user.admin_rss_links.find(:all ,:conditions => ["id in (#{params[:id]})"])
#    if links
#      links.each do |link|
#        link.destroy
#      end
#    end
#    render :update do |page|
#      page << "$('button_to_close').click();"
#      page << "notice('#{t :feed_url_deleted}')"
#    end
#  end
  def change_status
    link = AdminRssLink.find(params[:id])
    link.status = ((link.status)? false : true)
    if link.save
      render :update do |page|
        # page << "$('#rss_actions_#{link.id} a').html('#{((link.status)? 'Inactive': 'Activate')}')"
        page.replace_html "rss_status_#{link.id}" , :partial=>"status", :locals => {:link => link}
      end
    else
      render :update do |page|
        page << "notice('#{t :action_failed}')"
      end

    end
  end

  private

  def load_notifications
    @admin_rss_links_table = Grid::Admin::RssPresenter.new(@template)
    @admin_rss_links = AdminRssLink.all(:order => @admin_rss_links_table.order)
    @admin_rss_links = @admin_rss_links.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @admin_rss_links_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @admin_rss_links.size)
  end
end
