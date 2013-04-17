class SkinsController < ApplicationController

  before_filter :require_user, :except => [:apply_active_skin]

  def index
    @skin = current_user.active_skin
  end

  def create
    skins = current_user.skins.find_all_by_name(params[:name].strip)
    if params[:name].strip.blank?
      render :update do |page|
        page << 'notice("Name can\'t be blank")'
      end
    elsif !skins.blank? || params[:name] == Skin.edintity_default.name
      render :update do |page|
        page << 'notice("Name already exists")'
      end
    else
      current_user.create_skin(params[:name].strip)
      @default_skin = Skin.edintity_default
      @my_skins = current_user.skins
      render :update do |page|
        page << 'notice("Skin created successfully")'
        page << "$j('#newSkin').hide();"
        page << "$j('#new_skin_name').val('');"
        page.replace_html "your_skins", :partial => "skins/your_skins"
      end
    end 
  end

  def edit
    
  end

  def delete_skin
    skin = current_user.skins.find_by_id(params[:skin_id])
    skin.destroy if skin
    @default_skin = Skin.edintity_default
    @my_skins = current_user.skins
    render :update do |page|
      page << 'notice("Skin deleted successfully")'
      page.replace_html "your_skins", :partial => "skins/your_skins"
    end
  end

  def update_active_skin
    type = params[:panel_type]
    @skin = current_user.active_skin
    @skin.update_style_attribute(params, type) unless @skin == Skin.edintity_default
    render :update do |page|
      page << ('notice("Skin updated successfully.")')
    end
  end

  def upload_image
    type = params[:panel_type]
    skin = current_user.active_skin

    skin_style, image, base_url = skin.update_background_image_attribute(params, type)

    responds_to_parent do
      render :update do |page|
        page << "changeStyle('#{skin_style.style_attribute.name}', '#{skin_style.panel_type.element_name}', 'url(#{base_url})')"
        page << "changeStyle('background-repeat', '#{skin_style.panel_type.element_name}', '#{params[type]["background-repeat"]}')"
        page << "$('#{type}_background-image').value = 'url(#{base_url})'"
        page << "$j('#noImage').show();$j('#image_upload_spinner').hide()"
        page.insert_html :bottom,  "background_image_#{skin_style.panel_type.id}", :partial => "skins/background_images", :locals => {:skin_style => skin_style, :url => base_url, :image => image}
      end
    end
  end

  def delete_image
    skin = current_user.active_skin
    if !skin.blank? && !skin.skin_styles.blank?
      style_ids = []
      skin.skin_styles.each do |style|
        style_ids << style.id
      end
    end
    asset = Asset.find(:first, :conditions => ["attachable_type = 'SkinStyle' and attachable_id in (?) and id = ?", style_ids, params[:id]]) unless style_ids.blank?
    asset.destroy if asset
    render :update do |page|
      page << "$j('.bg_image_#{params[:id]}').html('')"
    end
  end

  def apply_active_skin
    user = User.find_by_id(params[:user])
    if user
      active_skin = user.active_skin
      if active_skin.blank? || active_skin.skin_styles.blank?
        active_skin = Skin.edintity_default
      end
      active_skin_styles = active_skin.skin_styles
      render :update do |page|
        PanelType.all.each do |panel_type|
          StyleAttribute.all.each do |style_attribute|
            skin_style = active_skin_styles.find_by_panel_type_id_and_style_attribute_id(panel_type.id, style_attribute)
            unless skin_style.blank?
              page << "changeStyle('#{skin_style.style_attribute.name}', '#{skin_style.panel_type.element_name}', '#{skin_style.attribute_value}')"
              if skin_style.style_attribute.name == 'color' && panel_type.name != 'body'
                links = skin_style.panel_type.element_name.gsub(',',' a,') + " a"
                page << "changeStyle('#{skin_style.style_attribute.name}', '#{links}', '#{skin_style.attribute_value}')"
              end
            end
          end
        end
      end
    end
  end

end
