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
  has_many :prizes


  def fetch_prizes params_prizes
    params_prizes = [{product_id: 1, probability: 0.01}, {product_id: 1, coin: 200, probability: 0.01}]
    prizes = []
    params_prizes.each do |params_prize|
      if params_prize[:product_id].present?
        prize = self.prizes.find_or_initialize_by product_id: product_id
      else
        prize = self.prizes.find_or_initialize_by coin: coin
      end
      prize.probability = params_prize[:probability]
      prizes << prize
    end
    self.prizes = prizes
    self.save
    self
  end

end
