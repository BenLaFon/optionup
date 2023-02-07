class AddNewToCompany < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :new, :boolean
  end
end
