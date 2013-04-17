namespace :payment_reminder do

	task :check_usage_cycle => :environment do
		puts "====== Starting Check Indivdual Usage Cycle ======="
    Payment.check_usage_cycle
		puts "====== Ending Check Indivdual Usage Cycle ======="
	end

	task :monthly_payment_reminders => :environment do
		puts "====== Starting Check Payment Reminders ======="
    Payment.monthly_payment_reminders
		puts "====== Ending Check Payment Reminders ======="
	end

  task :company_check_usage_cycle => :environment do
		puts "====== Starting Check Company Usage Cycle ======="
    Payment.check_company_usage_cycle
		puts "====== Ending Check Company Usage Cycle ======="
	end

  task :company_monthly_payment_reminders => :environment do
		puts "====== Starting Check Company Payment Reminders ======="
    Payment.company_monthly_payment_reminders
		puts "====== Ending Check Company Payment Reminders ======="
	end

end
