module ActionController
  class Base
    rescue_responses.merge!(
      'ActionController::SecurityTransgression' => :forbidden,
      'ActiveRecord::SecurityTransgression' => :forbidden
    )

    private

    def check_access_control_for(user, action, resource)
      raise(SecurityTransgression, "User (#{user.id || 'nil'}) cannot #{action} #{resource.class.name} (#{resource.id || 'nil'}).") unless user.send("can_#{action}?", resource)
    end
  end

  class SecurityTransgression < ActionControllerError
  end
end

module ActiveRecord
  class Base
    def creatable_by?(user)
      true
    end

    def readable_by?(user)
      true
    end

    def updatable_by?(user)
      true
    end

    def deletable_by?(user)
      true
    end

    def create_with_access_control
      #raise(SecurityTransgression, "User (#{User.current.id || 'nil'}) cannot create #{self.class.name} (#{self.id || 'nil'}).") unless User.current.can_create?(self)
      create_without_access_control
    end
    alias_method_chain :create, :access_control

    class << self
      def find_with_access_control(*args)
        returning resources = find_without_access_control(*args) do
          Array(resources).each do |resource|
         #   raise(SecurityTransgression, "User (#{User.current.id || 'nil'}) cannot read #{resource.class.name} (#{resource.id || 'nil'}).") unless User.current.can_read?(resource)
          end
        end
      end
      alias_method_chain :find, :access_control
    end

    def update_with_access_control
   #   raise(SecurityTransgression, "User (#{User.current.id || 'nil'}) cannot update #{self.class.name} (#{self.id || 'nil'}).") unless User.current.can_update?(self)
      update_without_access_control
    end
    alias_method_chain :update, :access_control

    def destroy_with_access_control
   #   raise(SecurityTransgression, "User (#{User.current.id || 'nil'}) cannot delete #{self.class.name} (#{self.id || 'nil'}).") unless User.current.can_delete?(self)
      destroy_without_access_control
    end
    alias_method_chain :destroy, :access_control

    def save_without_access_control
      create_or_update_without_access_control
    end

    private

    def create_or_update_without_access_control
      raise ReadOnlyRecord if readonly?
      result = new_record? ? create_without_access_control : update_without_access_control
      result != false
    end
  end

  class SecurityTransgression < ActiveRecordError
  end
end