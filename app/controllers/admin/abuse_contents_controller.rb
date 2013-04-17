class Admin::AbuseContentsController < ApplicationController
  before_filter :require_user
  before_filter :admin_required

  def index
    load_contents
  end

  def edit
    @abuse_content = AbuseContent.find(params[:id])
    render :layout=> "redbox"
  end

  def update
    @abuse_content = AbuseContent.find(params[:id])
    @abuse_content.update_attributes(params[:abuse_content])
    @reporter = User.find(@abuse_content.stream.abuse_reporter_id)
    stream = @abuse_content.stream
    if(params[:stream_action] == 'publish')
      stream.update_attribute("report_abuse", "")
      @abuse_content.destroy
    elsif(params[:stream_action] == 'block')
      stream.update_attribute("report_abuse", 2)
      stream.user.violation_count = stream.user.violation_count.to_i +  1
      stream.user.save
      if(stream.user.violation_count >= SiteConfiguration.violation_limit.value.to_i)
        stream.user.update_attribute("active", false)
        Notification.deliver_notification("Account blocked",stream.user, { "params" => {}}, :locale => session[:locale] == "arabic")
      end
      Notification.deliver_notification("Abuse Content Blocked - Owner",stream.user, { "params" => {}}, :locale => session[:locale] == "arabic")
      Notification.deliver_notification("Abuse Content Blocked - Reporter",@reporter, { "params" => {}}, :locale => session[:locale] == "arabic")
      @abuse_content.destroy
      Activity.add_points(@reporter, Activity::ACTIVITY_TYPES[:flag], 'Stream', stream.id, stream.user_id)
      Activity.add_points(stream.user, Activity::ACTIVITY_TYPES[:flagged], 'Stream', stream.id, @reporter.id)
    end
    load_contents
    render :update do |page|
     page.replace_html "abuse_content_list", :partial => 'index', :locals =>{:abuse_contents => @abuse_contents}
     page << "RedBox.close();"
     params[:stream_action].blank? ? page << "notice('Please provide some action on the stream')" : page << "notice('Abused content Modified successfully')"
    end
  end

  def destroy
    abuse_content = AbuseContent.find(params[:id])
    abuse_content.stream.update_attribute("report_abuse", "")
    if abuse_content.destroy
      render :update do |page|
        page << "Effect.Fade('abuse_content_#{abuse_content.id}')"
        page << "notice('Abused content deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete the content, please try again!')"
      end
    end
  end


  private
  def load_contents
    @abuse_contents_table = Grid::Admin::AbuseContentPresenter.new(@template)
    @abuse_contents = AbuseContent.all(:order => @abuse_contents_table.order)
    @abuse_contents = @abuse_contents.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @abuse_contents_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @abuse_contents.size)
  end
end
