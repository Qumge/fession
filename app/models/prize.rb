# == Schema Information
#
# Table name: prizes
#
#  id         :bigint           not null, primary key
#  coin       :integer
#  content    :string(255)
#  number     :integer
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#

class Prize < ApplicationRecord
end
