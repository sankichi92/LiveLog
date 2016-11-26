class AddPublicAndUrlAndIntroToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :public, :boolean, default: false
    add_column :users, :url, :string
    add_column :users, :intro, :text
  end
end
