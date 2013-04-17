class Admin::ReportedVideosController < ApplicationController
  before_filter :require_user
  before_filter :admin_required
  def index
    load_reported_videos
    render :layout => false if request.xhr?
  end

#  def process_spam
#    spammed_user = SpammedUser.find_by_id(params[:id])
#    spammed_user.process_spam_request(params)
#
#    render :update do |page|
#      page.replace_html "action_#{spammed_user.id}", params[:scope].blank? ? "<b>Marked As Spammer</b>" : "<b>#{params[:scope].capitalize}ed</b>"
#    end
#  end



  private


  def load_reported_videos
    @reported_videos_table = Grid::Admin::ReportedVideosPresenter.new(@template)
    @reported_videos = FlaggedVideo.all(:order => @reported_videos_table.order)
    @reported_videos = @reported_videos.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @reported_videos_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @reported_videos.size)
  end
end
