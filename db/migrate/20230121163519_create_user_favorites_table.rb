class CreateUserFavoritesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :user_favorites_tables do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
