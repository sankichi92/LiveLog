class AddIndexToLivesNameAndDate < ActiveRecord::Migration[5.0]
  def change
    add_index :lives, %i(name date), unique: true
  end
end
