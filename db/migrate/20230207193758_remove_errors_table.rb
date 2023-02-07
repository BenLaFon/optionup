class RemoveErrorsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :errors
  end
end
