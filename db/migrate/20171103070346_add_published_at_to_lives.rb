class AddPublishedAtToLives < ActiveRecord::Migration[5.1]
  def change
    add_column :lives, :published_at, :datetime
  end
end
