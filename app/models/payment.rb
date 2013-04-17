class Payment < ActiveRecord::Base

  belongs_to :user
  belongs_to :membership
  belongs_to :company

  named_scope :success, :conditions => ["status = 1"]
  named_scope :pending_payments, :conditions => ["status = 0"]

  STATUS ={
    :pending => 0,
    :success => 1,
    :failure => 2
  }

  STATUS_CODE ={
    0 => 'pending',
    1 => 'success',
    2 => 'failure'
  }

  def self.get_revenue_report(start_date, end_date, table_view = false)
    unless table_view
      data = {}
      Membership.paid_plans.each do |membership|
        data[membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]}
      end
      payments = self.success.find(:all, :select => "Date(created_at) AS date, membership_id, amount", :conditions => ["created_at >= ? and created_at <= ? and membership_id is not null", start_date, end_date])
      payments.each do |payment|
        data[payment.membership.name] = {DateTime.parse(start_date).to_i*1000 => [0], DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000 => [0]} if data[payment.membership.name].nil?
        data[payment.membership.name][DateTime.parse(payment.date).to_i*1000] = [] if data[payment.membership.name][DateTime.parse(payment.date).to_i*1000].blank?
        data[payment.membership.name][DateTime.parse(payment.date).to_i*1000] << payment.amount
      end
      data.blank? ? [['No data'], [[[DateTime.parse(start_date).to_i*1000, 0], [DateTime.parse(end_date.gsub('23:59:59','00:00:00')).to_i*1000, 0]]]] : [data.keys, Brand.flatten(data.values, true)]
    else
      payments = self.success.find(:all, :joins => [:membership], :select => "Date(payments.created_at) AS date, memberships.name as membership_name, sum(ifnull(payments.amount, 0)) as amount", :conditions => ["payments.created_at >= ? and payments.created_at <= ? and payments.membership_id is not null", start_date, end_date], :group => "date, payments.membership_id")
    end
  end

  def self.get_stats(membership_id = nil)
    unless membership_id.blank?
      payments = Payment.find(:all, :select => "sum(amount) as amount",:conditions => [ "membership_id in (?)", membership_id], :group => "membership_id")
    else
      payments = Payment.find(:all, :select => "sum(amount) as amount")
    end
    payments.first ? payments.first.amount.to_i : 0
  end

  def self.payment_reminders
    self.check_usage_cycle
    self.monthly_payment_reminders
  end

  def self.check_usage_cycle
    users = User.find(:all, :conditions => "active = 1")
    users.each do |user|
      cycle_start_date = user.cycle_start_date
      if cycle_start_date
        if cycle_start_date + 30.days < Time.now
          user.update_attributes({:cycle_start_date => cycle_start_date + 30.days, :uploaded_size => 0})
        end
      else
        user.update_attributes({:cycle_start_date => Time.now, :uploaded_size => 0})
      end
    end
  end

  def self.monthly_payment_reminders
    users = User.find(:all, :conditions => "active = 1")
    users.each do |user|
      membership = user.membership
      next_payment_date = user.next_payment_date
      if membership.amount != 0 && !next_payment_date.blank?
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

  def self.company_payment_reminders
    self.check_company_usage_cycle
    self.company_monthly_payment_reminders
  end

  def self.check_company_usage_cycle
    companies = Company.find(:all, :conditions => "active = 1")
    companies.each do |company|
      cycle_start_date = company.cycle_start_date
      if cycle_start_date
        if cycle_start_date + 30.days < Time.now
          company.update_attributes({:cycle_start_date => cycle_start_date + 30.days, :uploaded_size => 0})
        end
      else
        company.update_attributes({:cycle_start_date => Time.now, :uploaded_size => 0})
      end
    end
  end

  def self.company_monthly_payment_reminders
    companies = Company.find(:all, :conditions => "active = 1")
    companies.each do |company|
      membership = company.membership
      next_payment_date = company.next_payment_date
      if membership.amount != 0 && !next_payment_date.blank?
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
