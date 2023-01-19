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


  def self.calc_per_move
    if Record.all.where(sma_10: nil).count.positive?
      self.calc_sma
    end
    ActiveRecord::Base.connection.execute("UPDATE records SET per_move_100_200 = (sma_100::double precision - sma_200::double precision) / sma_200::double precision * 100.000000")
    p "per_move_100_200 run"
    ActiveRecord::Base.connection.execute("UPDATE records SET per_move_50_200 = (sma_50::double precision - sma_200::double precision) / sma_200::double precision * 100.00000")
    p "per_move_50_200 run"
    ActiveRecord::Base.connection.execute("UPDATE records SET per_move_30_200 = (sma_30::double precision - sma_200::double precision) / sma_200::double precision * 100.00000")
    p "per_move_30_200 run"
    ActiveRecord::Base.connection.execute("UPDATE records SET per_move_20_200 = (sma_20::double precision - sma_200::double precision) / sma_200::double precision * 100.00000")
    p "per_move_20_200 run"
    ActiveRecord::Base.connection.execute("UPDATE records SET per_move_10_200 = (sma_10::double precision - sma_200::double precision) / sma_200::double precision * 100.00000")
    p "per_move_10_200 run"
    ActiveRecord::Base.connection.execute("UPDATE records SET per_move_close_50 = (close::double precision - sma_50::double precision) / sma_50::double precision * 100.000000")
    p "per_move_close_50 run"
  end

  def self.calc_sma
    if Record.all.where(close: nil).count.positive?
      p "There are nils in the close column"
      return
    end
    start_time = Time.now
    puts "start time #{start_time}"
    ranges = {"10" => "sma_10", "20" => "sma_20", "30" => "sma_30", "50" => "sma_50", "100" => "sma_100", "200" => "sma_200"  }

    ranges.each do |num, word|
      sql = <<~EOS
            WITH v_table AS
            (SELECT a.date,a.close,a.id,
            AVG(a.close)
            OVER( PARTITION BY company_id ORDER BY a.date ROWS BETWEEN #{num} PRECEDING AND CURRENT ROW)
            AS #{word}
            FROM records a)
            UPDATE records set #{word} = v_table.#{word}
            FROM v_table
            WHERE records.id = v_table.id AND records.#{word} IS NULL
            EOS
      ActiveRecord::Base.connection.execute(sql)
      p "#{word} avgs run"
    end
    end_time = Time.now
    puts "ended #{end_time}| total time was #{end_time - start_time} "

    Record.all.where(sma_10: nil).count.positive? ? p("sma_10 still has nils") : p("sma_10 has no nils")

  end

end
