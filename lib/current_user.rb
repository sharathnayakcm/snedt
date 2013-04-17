module ActionController
  class Base
#    before_filter :set_current_user
#
#    def set_current_user
#      session.delete if session['user'] # TODO: Remove this line after we think all the old sessions are gone.
#      Thread.current[:user] = session['user_id'] ? User.find_without_access_control(session['user_id']) : nil
#      User.current = nil if User.current.deleted_at
#    end
#
#    def current_user
#      @current_user ||= User.current
#    end
#    helper_method :current_user
 end
end