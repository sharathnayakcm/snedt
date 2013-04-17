class Skin < ActiveRecord::Base

  belongs_to :user
  belongs_to :brand
  has_many :skin_styles

  def self.edintity_default
    Skin.find_by_name('edintity_default', :conditions => "(user_id is null or user_id = 0)")
  end

  def update_style_attribute(params, type)
    unless type.blank?
      params[type].each do |key, value|
        value = key == "border" ? "1px solid #{value}" : value
#        raise "#{value}" if type == "border"
        current_style = self.skin_styles.find_by_panel_type_id_and_style_attribute_id(params[:panel_type_id], StyleAttribute::TYPE_IDS[key])
        if current_style.blank?
          self.skin_styles.create(:style_attribute_id => StyleAttribute::TYPE_IDS[key], :panel_type_id => params[:panel_type_id], :attribute_value => value)
        else
          current_style.update_attribute(:attribute_value, value)
        end
      end
    end
  end


  def update_background_image_attribute(params, type)
    skin_style = self.skin_styles.find_by_panel_type_id_and_style_attribute_id(params[:panel_type_id], StyleAttribute::TYPE_IDS["background-image"])
    if skin_style.blank?
      skin_style = self.skin_styles.create(:style_attribute_id => StyleAttribute::TYPE_IDS["background-image"], :panel_type_id => params[:panel_type_id])
    end
    unless type.blank?
      asset = Asset.new({:asset => params[:asset][:file]})
      asset.user_id = self.user_id
      asset.attachable_id = skin_style.id
      asset.attachable_type = "SkinStyle"
      asset.save
#      skin_style.update_attribute(:attribute_value, "url(#{asset.asset.url.gsub('/s3.','/s3-eu-west-1.')})")
    end
    [skin_style, asset, asset.asset.url.gsub('/s3.','/s3-eu-west-1.')]
  end
end
