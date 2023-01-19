class CreateRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :records do |t|
      t.references :company, null: false, foreign_key: true
      t.references :date, null: false, foreign_key: true
      t.date :date, null: false
      # base stats
      t.decimal :high, precision: 15, scale: 4, null: false
      t.decimal :low, precision: 15, scale: 4, null: false
      t.decimal :open, precision: 15, scale: 4, null: false
      t.decimal :close, precision: 15, scale: 4, null: false
      t.integer :volume, null: false

      #first round calculations
      t.decimal :sma_10, precision: 15, scale: 4
      t.decimal :sma_20, precision: 15, scale: 4
      t.decimal :sma_30, precision: 15, scale: 4
      t.decimal :sma_50, precision: 15, scale: 4
      t.decimal :sma_100, precision: 15, scale: 4
      t.decimal :sma_200, precision: 15, scale: 4

      #second round calculations
      t.decimal :per_move_100_200, precision: 15, scale: 4
      t.decimal :per_move_50_200, precision: 15, scale: 4
      t.decimal :per_move_30_200, precision: 15, scale: 4
      t.decimal :per_move_20_200, precision: 15, scale: 4
      t.decimal :per_move_10_200, precision: 15, scale: 4
      t.decimal :per_move_close_50, precision: 15, scale: 4

      add_index :records, [:company_id, :date], unique: true

      t.timestamps
    end
  end
end
