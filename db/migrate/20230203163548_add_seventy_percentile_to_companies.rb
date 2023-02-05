class AddSeventyPercentileToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :seventy_percentile, :decimal
  end
end
