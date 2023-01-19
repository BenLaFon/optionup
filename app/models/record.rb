class Record < ApplicationRecord
  belongs_to :company
  belongs_to :date
  validate :unique_record



  private

  def unique_record
    p "checking"
    result = ActiveRecord::Base.connection.execute("SELECT * FROM records
    WHERE company_id = #{self.company_id} AND date = '#{self.date}'")
    if result.count > 0
      errors.add(:date, "already has a daily stat for this company")
      p "Unique validation failed"
      return
    end
    p "Uniqueness validated, saving"

  end
end
