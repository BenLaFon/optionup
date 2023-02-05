class AddLevelTwoToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :query_2_status, :integer, default: 0
  end
end
