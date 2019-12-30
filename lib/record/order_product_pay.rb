class Record::OrderProductPay < Record

  def records_scope
    ::OrderProduct.joins(:order, {product: :task_product_task})
  end

  def search_conn
    conn = ["orders.status != 'wait'"]
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
      s[date] = data.present? ? data.sum{|d| d.amount}.to_f / 100 : 0
    end
    s
  end

  def date_record_number
    s = {}
    date_headers.each do |date|
      data = date_group_records[date]
      s[date] = data.present? ? data.sum{|d| d.number} : 0
    end
    s
  end


end