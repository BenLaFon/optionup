class CreateErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :errors do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :status, default: 0
      t.string :message

      t.timestamps
    end
  end
end
