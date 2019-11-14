class CreateSmsRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_records do |t|
      t.string :region_id
      t.string :phone
      t.string :sign
      t.string :code
      t.string :params
      t.string :up_extend_code
      t.string :out_id
      t.string :status
      t.string :request_id
      t.string :message
      t.string :biz_id
      t.timestamps
    end
  end
end
