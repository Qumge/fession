# == Schema Information
#
# Table name: prizes
#
#  id          :bigint           not null, primary key
#  coin        :integer
#  content     :string(255)
#  deleted_at  :datetime
#  number      :integer
#  probability :float(24)
#  type        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  game_id     :integer
#  product_id  :integer
#
# Indexes
#
#  index_prizes_on_deleted_at  (deleted_at)
#

class Prize::ProductPrize < Prize

end
