class AddQueryStatusToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :query_1_status, :integer, default: 0
  end
end
