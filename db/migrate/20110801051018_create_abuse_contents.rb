class CreateAbuseContents < ActiveRecord::Migration
  def self.up
    create_table :abuse_contents do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :abuse_contents
  end
end
