class MakeColumnsNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :lives, :name, false
    change_column_null :lives, :date, false
    change_column_null :playings, :user_id, false
    change_column_null :playings, :song_id, false
    change_column_null :songs, :live_id, false
    change_column_null :songs, :name, false
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
    change_column_null :users, :furigana, false
    change_column_null :users, :joined, false
  end
end
