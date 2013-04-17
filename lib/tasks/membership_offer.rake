namespace :membership_offer do

  task :free_to_premium => :environment do
    users = User.active.free_users
    users.each do |user|
      puts "---------------------------"
      puts "Upgrading - #{user.id} - #{user.full_name}"
      user.update_attributes({:membership_id => 2, :cycle_start_date => Time.now, :uploaded_size => 0})
      user.payments.create(:amount => 0, :vendor => "Free Trial 30 days", :status => true, :membership_id => 2)
      puts "Upgraded - #{user.id} -  - #{user.full_name}"
      puts "---------------------------"
    end

  end
end