class AddTrialPeriodToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :is_trial_period_allowed, :boolean, :default => false
    add_column :memberships, :trial_period, :integer
  end

  def self.down
    remove_column :memberships, :is_trial_period_allowed
    remove_column :memberships, :trial_period
  end
end
