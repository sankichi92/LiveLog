class MakeRefreshTokenNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null :google_credentials, :refresh_token, true
  end
end
