class CreateServiceConfigurations < ActiveRecord::Migration
  def self.up
    create_table :service_configurations do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :service_configurations
  end
end
