class Record::ProductCoinLog < Record

  def records_scope
    ::CoinLog.joins(order_product: :order)
  end

  def search_conn
    conn = ["coin_logs.channel = 'product'"]
    if @date_from.present?
      conn << "orders.payment_at >= '#{@date_from}'"
    end
    if @date_to.present?
      conn << "orders.payment_at < '#{@date_to}'"
    end
    if @company_id.present?
      conn << "orders.company_id = #{@company_id}"
    end
    conn.join ' and '
  end

  def records
    records_scope.where search_conn
  end

  def date_records
    s = {}
    date_headers.each do |date|
      data = date_group_records[date]
      s[date] = data.present? ? data.sum{|d| d.coin.to_i} : 0
    end
    s
  end


end