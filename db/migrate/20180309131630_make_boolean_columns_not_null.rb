class MakeBooleanColumnsNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :lives, :published, false
    change_column_null :users, :admin, false
    change_column_null :users, :activated, false
    change_column_null :users, :public, false
  end
end
