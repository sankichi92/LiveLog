class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :furigana
      t.string :nickname
      t.string :email
      t.date :joined

      t.timestamps
    end
  end
end
