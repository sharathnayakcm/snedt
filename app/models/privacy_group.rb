class PrivacyGroup < ActiveRecord::Base
  belongs_to :user

  def grp_array
    ["#{self.name}", "PG-#{self.id}"]
  end

  def has_this_user(user)
    self.user_ids.blank? ? false : self.user_ids.split(",").include?(user.to_s)
  end


  def self.add_user_to_groups(group_id, user)
    unless group_id.blank?
      privacy_group = PrivacyGroup.find(group_id)
      privacy_group.each do |pg|
        unless pg.group_user_ids.blank?
          unless pg.group_user_ids.split(',').include?(user.to_s)
            group_user_ids_value = pg.group_user_ids.to_s + ',' + user.to_s
          else
            group_user_ids_value = pg.group_user_ids.to_s
          end
        else
          group_user_ids_value = user
        end
        pg.update_attribute(:group_user_ids, group_user_ids_value)
      end
    end
  end

  def self.remove_user_from_groups(group_id, user, current_user)
    groups = group_id.blank? ? current_user.privacy_groups : current_user.privacy_groups.find(:all, :conditions => ["id not in (?)", group_id])
    groups.each do |grp|
      unless grp.group_user_ids.blank?
        ids = grp.group_user_ids.split(',')
        id_index = ids.index(user.to_s)
        if id_index
          ids.delete_at(id_index)
        end
        new_ids = ids * ','
        grp.update_attribute(:group_user_ids, new_ids)
      end
    end
  end

end
