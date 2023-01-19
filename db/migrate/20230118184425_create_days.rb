class CreateDays < ActiveRecord::Migration[7.0]
  def change
    create_table :days do |t|
      t.date :date
      t.integer :number_over_50_day
      t.integer :total_active_companies
      t.decimal :percentage_over_50

      t.timestamps
    end
  end
end
