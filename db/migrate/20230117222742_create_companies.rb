class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :ticker
      t.string :industry
      t.string :sector
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
