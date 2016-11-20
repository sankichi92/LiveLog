class ChangeJoinedColumnsOnUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :joined, :date
    add_column :users, :joined, :integer
  end
end
