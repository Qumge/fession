# == Schema Information
#
# Table name: games
#
#  id           :bigint           not null, primary key
#  coin         :string(255)
#  cost         :integer
#  deleted_at   :datetime
#  desc         :text(65535)
#  name         :string(255)
#  residue_coin :bigint
#  type         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#
# Indexes
#
#  index_games_on_deleted_at  (deleted_at)
#

class Game::Scratch < Game

end
