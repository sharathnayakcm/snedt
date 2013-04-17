class Notification < ActiveRecord::Base
  has_and_belongs_to_many :users

  def self.deliver_notification(name, recipient, options = {}, arabic = {:locale=>false})
		notification = find_by_code(name)
		notification.deliver_notification(recipient, options, arabic) if notification
	end

  def deliver_notification(recipient, options = {}, arabic = {:locale=>false})
		Notifier.deliver_notification(self, recipient, options, arabic) if active?
	end

  def render(other_vars = {})
		liquified = {}

		other_vars.each {|name, value| liquified[name] = liquify(value)}
		vars = {'templateable' => liquify(self)}.merge(liquified)
    
    Liquid::Template.register_filter(ApplicationHelper)
    if other_vars["arabic"]
      Liquid::Template.parse(self.content_arabic).render(vars)
    else
      Liquid::Template.parse(self.content).render(vars)
    end
	end

	private

	def liquify(var)
		if var.respond_to?(:to_liquid)
			var.to_liquid
		#elsif var.respond_to?(:attributes)
		#	var.attributes.stringify_keys
	  elsif var.kind_of?(Array)
	    var.map {|e| liquify(e)}
	  elsif var.kind_of?(Hash)
	    var.each do |k,v|
	      var[k.to_s] = liquify(v)
	    end

	    var
		else
			var
		end
	end

end
