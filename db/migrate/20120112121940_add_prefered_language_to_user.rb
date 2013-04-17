class AddPreferedLanguageToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :prefered_language, :string, :default => "en"
  end

  def self.down
    remove_column :users, :prefered_language
  end
end
