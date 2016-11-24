class AddIndexToUsersFurigana < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :furigana
  end
end
