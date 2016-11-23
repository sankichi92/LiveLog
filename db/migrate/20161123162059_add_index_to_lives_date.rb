class AddIndexToLivesDate < ActiveRecord::Migration[5.0]
  def change
    add_index :lives, :date
  end
end
