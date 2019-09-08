class DropTokens < ActiveRecord::Migration[6.0]
  def change
    drop_table :tokens
  end
end
