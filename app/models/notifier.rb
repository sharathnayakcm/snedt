class Notifier < ActionMailer::Base
  default_url_options[:host] = "edintity.com"
  #  default_url_options[:port] = 3011

	def notification(notifier, recipient, options = {}, arabic = {:locale=>false})
		recipients recipient.email unless recipient.blank?
    if arabic[:locale]
      subject notifier.subject_arabic
    else
      email_subject =  notifier.subject.blank? ? "" : notifier.subject.gsub('Username', options["params"]["user_name"] || "")
      subject email_subject
    end

		copy_to = notifier.cc ? notifier.cc.split(',') : []
    bcc_to = notifier.bcc ? notifier.bcc.split(',') : []

		cc(copy_to) unless copy_to.empty?
		bcc(bcc_to) unless bcc_to.blank?
		from "no-reply@edintity.com"
    #		content_type "multipart/alternative"

    #		notifier.templates.each do |template|
    part :content_type => "text/html", :body => notifier.render(options.merge!('recipient' => recipient.instance_values['attributes'], 'arabic' => arabic[:locale]))
    #		end
	end


  def error_message(exception, session, params, request)
    setup_email
    @subject    = 'New Exception in edintity.com'
    @body["exception"] = exception.message
    @body["trace"] = exception.backtrace
    @body["session"] = session
    @body["params"] = params
    @body["request"] = request
    @recipients = ["subith.sivaraman@sumerusolutions.com", "senthil.krishnamoorthy@sumerusolutions.com"]
    @sent_on    = Time.now
    @content_type  = 'text/html'
  end

  def setup_email
    @from       = 'no-reply@edintity.com'
    @sent_on    = Time.now
    @headers    = {}
  end

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          "noreply@#{EMAIL_HOST}"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def change_password(user)
    subject       "Change Password Instructions"
    from          "noreply@#{EMAIL_HOST}"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
  
  def activation_instructions(user)
    subject       "Activation Instructions"
    from          "noreply@#{EMAIL_HOST}" # Removed name/brackets around 'from' to resolve "555 5.5.2 Syntax error." as of Rails 2.3.3
    recipients    user.email
    sent_on       Time.now
    body          :account_activation_url => activate_url(user.perishable_token)
  end

  def welcome(user)
    subject       "Welcome to the site!"
    from          "noreply@#{EMAIL_HOST}"
    recipients    user.email
    sent_on       Time.now
    body          :root_url => root_url
  end

  def invite_friend(recipient, user)
    subject       "You have been invited to edintity.com"
    from          "noreply@#{EMAIL_HOST}"
    recipients    recipient
    sent_on       Time.now
    body          :user => user
    content_type  "text/html"
  end

end  