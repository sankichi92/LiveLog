class AddApiDigestToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :api_digest, :string
  end
end
