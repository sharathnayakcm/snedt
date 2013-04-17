class TagsController < ApplicationController

  def create
    begin
      @stream = Stream.find(params[:stream_id])
      #      tags = @stream.stream_tags_array
      #      if tags.include?(params[:stream][:tag]) || tags.size >= 5
      #        render :update do |page|
      ##          page << "$('tag_div_#{params[:id]}').style.display='none';"
      #          if tags.size >= 5
      #            page << "notice('#{t :tag_limit}')"
      #          else
      #            page << "notice('#{t :tag_already_taken}')"
      #          end
      #        end
      #      else
      tags = params[:tags] || []
      if tags.size > 5
        render :update do |page|
          #            page << "$('tag_div_#{params[:stream_id]}').style.display='none';"
          page << "notice('#{t :tag_limit}')"
        end
      else
        @stream.stream_tags.destroy_all if @stream.stream_tags
        tags.each do |t|
          existing = current_user.tags.find_by_name(t)
          unless existing.blank?
            @stream.stream_tags.create(:tag_id => existing.id)
          else
            new = current_user.tags.create(:name => t)
            @stream.stream_tags.create(:tag_id => new.id)
          end
        end
        render :update do |page|
#          page.replace_html "stream_tags_#{params[:stream_id]}", :partial => "streams/stream_tags", :locals => {:stream => @stream}
          page << "$j('#stream_add_tag_#{params[:stream_id]}').hide();"
          page << "notice('#{t :tag_posted}')"
        end
      end
      #      end
    rescue Exception => e
      render :update do |page|
        page << "notice('#{t :unable_to_create_tag}')"
      end
    end
  end

  def delete
    begin
      stream = current_user.streams.find_by_id(params[:stream_id])
      stream_tag = current_user.stream_tags.find_by_id(params[:stream_tag])
      if stream_tag
        tag_name = stream_tag.tag.name if stream_tag.tag
        stream_tag.destroy
      end
      render :update do |page|
        page << "notice('#{t :tag_deleted}')"
        page << "$j('#tags_#{stream.id} #close-#{tag_name}').click();"
        page.replace_html "stream_tags_#{params[:stream_id]}", :partial => "streams/stream_tags", :locals => {:stream => stream}
      end
    rescue
    end
  end
  
end
