class AddSubscribingToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :subscribing, :boolean, null: false, default: true
  end
end
