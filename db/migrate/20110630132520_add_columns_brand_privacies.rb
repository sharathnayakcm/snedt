class AddColumnsBrandPrivacies < ActiveRecord::Migration
  def self.up
    add_column :brand_privacies, :profile, :integer
    add_column :brand_privacies, :rss, :integer
    add_column :brand_privacies, :stream, :integer
  end

  def self.down
    remove_column :brand_privacies, :profile, :integer
    remove_column :brand_privacies, :rss, :integer
    remove_column :brand_privacies, :stream, :integer
  end
end
