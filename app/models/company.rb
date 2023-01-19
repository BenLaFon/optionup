class Company < ApplicationRecord
  has_many :records
  validates :ticker, presence: true, uniqueness: true
end
