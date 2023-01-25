class AddColorCodeToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :color_code, :integer, default: 0
  end
end
