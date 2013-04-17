class Streams::CommentsController < ApplicationController
  layout "application"
  before_filter :require_user,:find_stream_id

  def index
    @comments = @stream.comments.find(:all)
  end

  def create
    @comment = @stream.comments.new()
    @comment.description = params[:comment][:description]
    @comment.user_id = current_user.id
    if @comment.save
      Activity.add_points(current_user, Activity::ACTIVITY_TYPES[:comment], 'Stream', @stream.id, @stream.user_id)
      Activity.add_points(@stream.user, Activity::ACTIVITY_TYPES[:commented], 'Stream', @stream.id, current_user.id) unless current_user == @stream.user
      if params[:post_to_facebook] && @stream.user_service
        fb_comment_id = UserSession.post_facebook_comment(@stream, @stream.user_service, params[:comment][:description])
        @comment.update_attributes({:fb_comment_id => fb_comment_id["id"]}) if fb_comment_id
      end
      if params[:post_to_twitter] && @stream.user_service
        reply = TwitterAccount.post_twitter_reply(@stream, @stream.user_service, params[:comment][:description])
        @comment.update_attributes({:twitter_reply_id => reply[2].to_s}) if reply[2]
      end
      @comment.deliver_notification(url_for(profiles_path(:id => @comment.user.user_name, :only_path => false )), url_for(stream_path(:id => @stream.id, :only_path => false )),  :locale => session[:locale] == "arabic")
      render :update do |page|
        page.replace_html "stream_comments_#{@stream.id}", :partial => "comments/index", :locals => {:comments => @stream.comments, :stream => @stream}
        page << "$j('#write_comment_#{@stream.id}').hide();"
        page << "$j('#comment_#{@stream.id}').val('')"
        page << "$j('#add_comment_spinner_#{@stream.id}').addClass('hide')"
        page << "$j('.comment_count_#{@stream.id}').html('#{@stream.comments.count} comments')"
        page << "notice('#{t :comment_posted}')"
      end     
    else
      render :action =>'new'
    end
  end

  def find_stream_id
    @stream = Stream.find(params[:stream_id], :include => [:service, :user])
  end

  def index
    create
  end

  def delete
    comment = Comment.find(params[:id])
    comment.destroy if comment
    render :update do |page|
      page.replace_html "stream_comments_#{@stream.id}", :partial => "comments/index", :locals => {:comments => @stream.comments, :stream => @stream}
      page << "$j('.comment_count_#{@stream.id}').html('#{@stream.comments.count} comments')"
      page << "notice('#{t :comment_deleted}')"
    end
  end

end
