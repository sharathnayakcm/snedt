class TopicsController < ApplicationController
  before_filter :require_user
  def index
    @topics = Topic.all.sort_by{|obj| obj.points(current_user)}.reverse
    @user = User.find(params[:user_id]) if params[:user_id].present?
  end


  def show_followers
    @topic = Topic.find(params[:id])
    @users = @topic.users
    @users = @users.sort { |a, b| a.created_at <=> b.created_at }
    @users = @users.paginate({ :page => params[:page], :per_page => 10}) unless @users.blank?

  end

  def sign_up_topics
    @topic = Topic.find_by_id(params[:topic_id])
    @topic.users << current_user
    render :update do |page|
      page << "notice('#{t :topic_follow_notice} #{@topic.title}')"
    end
  end

  def show
    @topic = Topic.find(params[:id])
  end

  def new
    @topic = Topic.new
  end

  def add_topic_tag
    @topic = Topic.new
    @stream = Stream.find(params[:stream_id])
    @user_tags = @stream.stream_tags.map{|t| t.tag.name}.join(",")
    @tags = current_user.tags.map.collect{|tag| tag.name}.join(",")
    @header = "Add To Topic"
    render :layout => "redbox"
  end

  def add_user_topic
    @user = User.find(params[:id])
    params[:topic_name_ids].each do |topic_id|
      @topic = Topic.find_by_id(topic_id)
      if @user.topics.find_by_id(topic_id).blank?
        @user.topics<<(@topic)
      else
        @user.topics.delete(@topic)
      end
    end
    render :update do |page|
      page << "RedBox.close();" unless params[:signup]
    end

  end

  def add_stream_topic_and_tag
    if params[:id]
      @stream = Stream.find(params[:stream_id])
      @topic = Topic.find_by_id(params[:id])
      @stream.update_attribute(:topic_id, params[:id])
      #      render :update do |page|
      #        page << "notice('#{t :added_topic_sucessfully}')"
      #        #page << "$j('#social_inbox_topics_#{params[:stream_id]}').html(\"<a style='font-weight:bold;'>#{current_user.full_name}</a> added to topic <a style='font-weight:bold;'>#{@topic.title}</a> \")"
      #        #page << "$j('#social_topics_#{params[:stream_id]}').hide();"
      #        page << "RedBox.close();"
      #      end
    end
    if params[:tags]
      @stream = Stream.find(params[:stream_id])
      tags = params[:tags] || []
      @stream.stream_tags.destroy_all if @stream.stream_tags
      @tags = tags.split(",")
      @tags.each do |t|
        existing = current_user.tags.find_by_name(t)
        unless existing.blank?
          @stream.stream_tags.create(:tag_id => existing.id)
        else
          new = current_user.tags.create(:name => t)
          @stream.stream_tags.create(:tag_id => new.id)
        end
      end
    end
    render :update do |page|
      page << "notice('#{t :added_topic_sucessfully}')"
      page << "RedBox.close();"
      page.replace_html "selected_tags_#{params[:stream_id]}", :partial => "topics/stream_tags",:locals => {:tags => tags}
      page.replace_html "added_topic_img_#{params[:stream_id]}","<img height='25px' title='sharath' src='/images/brandPicMed.jpg' class='stream_topic_img'>"
    end
  end
  

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:notice] = "Successfully created topic."
      redirect_to @topic
    else
      render :action => 'new'
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "Successfully updated topic."
      redirect_to @topic
    else
      render :action => 'edit'
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    flash[:notice] = "Successfully destroyed topic."
    redirect_to topics_url
  end
end
