class CreateLives < ActiveRecord::Migration[5.0]
  def change
    create_table :lives do |t|
      t.string :name
      t.date :date
      t.string :place

      t.timestamps
    end
  end
end
