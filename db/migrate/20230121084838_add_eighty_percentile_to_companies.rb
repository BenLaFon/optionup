class AddEightyPercentileToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :eighty_percentile, :decimal
  end
end
