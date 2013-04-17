class AddConfigurationFieldsToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :api_token, :text
    add_column :services, :api_key, :text
    add_column :services, :active, :boolean
    add_column :services, :service_configuration_ids, :string
    add_column :user_services, :service_configuration_ids, :string
  end

  def self.down
    remove_column :services, :api_token
    remove_column :services, :api_key
    remove_column :services, :active
    remove_column :services, :service_configuration_ids
    adremove_columnd_column :user_services, :service_configuration_ids
  end
end
