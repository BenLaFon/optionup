class Record < ApplicationRecord
  belongs_to :company
  belongs_to :day, optional: true
  validates :date, presence: true
  validates :date, uniqueness: { scope: :company_id,
    message: "Uniqueness on company and date" }
  validates :company, presence: true
  validates :open, presence: true
  validates :high, presence: true
  validates :low, presence: true
  validates :close, presence: true
  validates :volume, presence: true




  private

end
