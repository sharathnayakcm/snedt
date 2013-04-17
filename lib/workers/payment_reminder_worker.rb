class PaymentReminderWorker < BackgrounDRb::MetaWorker
  set_worker_name :payment_reminder_worker
  reload_on_schedule true

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def payment_reminders
    check_usage_cycle
    monthly_payment_reminders
  end

  def check_usage_cycle
    users = User.find(:all, :conditions => "active = 1")
    users.each do |user|
      cycle_start_date = user.cycle_start_date
      if cycle_start_date
        unless cycle_start_date + 2592000 < Time.now
          user.update_attributes({:cycle_start_date => Time.now, :uploaded_size => 0})
        end
      else
        user.update_attributes({:cycle_start_date => Time.now, :uploaded_size => 0})
      end
    end
  end

  def monthly_payment_remiders
    users = User.find(:all, :conditions => "active = 1")
    users.each do |user|
      membership = user.membership
      unless membership.amount == 0
        next_payment_date = user.next_payment_date
        if next_payment_date > Time.now
          user.downgrade.destroy if user.downgrade
          user.update_attributes({:membership_id => 1, :free_user_since => Time.now})
        elsif (next_payment_date - 86400).strftime("%m/%d/%y") == Time.now.strftime("%m/%d/%y")
          Notification.deliver_notification("Monthly Payment Reminder", user, { "params" => {:days => 1, :url => root_url}})
        elsif (next_payment_date - 259200).strftime("%m/%d/%y") == Time.now.strftime("%m/%d/%y")
          Notification.deliver_notification("Monthly Payment Reminder", user, { "params" => {:days => 3, :url => root_url}})
        elsif (next_payment_date - 604800).strftime("%m/%d/%y") == Time.now.strftime("%m/%d/%y")
          Notification.deliver_notification("Monthly Payment Reminder", user, { "params" => {:days => 7, :url => root_url}})
        end
      end
    end
  end

  #This is for Company Payment reminder
  
  def company_payment_reminders
    check_company_usage_cycle
    company_monthly_payment_reminders
  end

    def check_usage_cycle
    companies = Company.find(:all, :conditions => "active = 1")
    companies.each do |company|
      cycle_start_date = company.cycle_start_date
      if cycle_start_date
        unless cycle_start_date + 2592000 < Time.now
          company.update_attributes({:cycle_start_date => Time.now, :uploaded_size => 0})
        end
      else
        company.update_attributes({:cycle_start_date => Time.now, :uploaded_size => 0})
      end
    end
  end

    def company_monthly_payment_remiders
    companies = Company.find(:all, :conditions => "active = 1")
    companies.each do |company|
      membership = company.membership
      unless membership.amount == 0
        next_payment_date = company.next_payment_date
        if next_payment_date > Time.now
          company.update_attributes({:active => false})
        elsif (next_payment_date - 86400).strftime("%m/%d/%y") == Time.now.strftime("%m/%d/%y")
          Notification.deliver_notification("Monthly Payment Reminder", company, { "params" => {:days => 1, :url => root_url}})
        elsif (next_payment_date - 259200).strftime("%m/%d/%y") == Time.now.strftime("%m/%d/%y")
          Notification.deliver_notification("Monthly Payment Reminder", company, { "params" => {:days => 3, :url => root_url}})
        elsif (next_payment_date - 604800).strftime("%m/%d/%y") == Time.now.strftime("%m/%d/%y")
          Notification.deliver_notification("Monthly Payment Reminder", company, { "params" => {:days => 7, :url => root_url}})
        end
      end
    end
  end

end


