class AddPublishedToLives < ActiveRecord::Migration[5.1]
  def change
    add_column :lives, :published, :boolean, default: false
  end
end
