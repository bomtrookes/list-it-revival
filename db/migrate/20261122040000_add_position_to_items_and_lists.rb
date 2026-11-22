class AddPositionToItemsAndLists < ActiveRecord::Migration[8.1]
  def change
    # Items: the ranking inside a list. Lists: the order on their owner's profile.
    add_column :items, :position, :integer
    add_column :lists, :position, :integer
    add_index :items, [:list_id, :position]
  end
end
