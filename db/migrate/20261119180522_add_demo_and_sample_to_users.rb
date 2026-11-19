class AddDemoAndSampleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :demo, :boolean, default: false, null: false
    # Fake users from the original sample data (they have random passwords and cannot log in)
    add_column :users, :sample, :boolean, default: false, null: false
  end
end
