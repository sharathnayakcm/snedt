class SpammedUser < ActiveRecord::Base
  belongs_to :user, :dependent => :destroy
  belongs_to :spammed_by, :class_name => "User", :foreign_key => "spammed_by_id"

  def process_spam_request(params)
    result = !(['reject', 'reveal'].include?(params[:scope]))
    self.update_attributes( :is_spammer => result,
                            :revealed_at => ['reject', 'reveal'].include?(params[:scope]) ? Time.now : "")
    self.user.update_attribute(:is_spammer, result)
  end
end
