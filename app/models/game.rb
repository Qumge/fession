# == Schema Information
#
# Table name: games
#
#  id           :bigint           not null, primary key
#  coin         :string(255)
#  cost         :integer
#  name         :string(255)
#  residue_coin :bigint
#  type         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#

class Game < ApplicationRecord
  validates_presence_of :cost, if: proc{|game| game.company.present?}
  validates_presence_of :coin
  validates_presence_of :company_id, if: proc{|game| game.cost.present?}
end
