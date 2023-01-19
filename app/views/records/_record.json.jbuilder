json.extract! record, :id, :company_id, :date_id, :high, :low, :open, :close, :volume, :created_at, :updated_at
json.url record_url(record, format: :json)
