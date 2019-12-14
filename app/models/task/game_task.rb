# == Schema Information
#
# Table name: tasks
#
#  id           :bigint           not null, primary key
#  coin         :bigint
#  deleted_at   :datetime
#  name         :string(255)
#  residue_coin :bigint
#  status       :string(255)
#  type         :string(255)
#  valid_from   :datetime
#  valid_to     :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#  model_id     :integer
#
# Indexes
#
#  index_tasks_on_deleted_at  (deleted_at)
#

class Task::GameTask < Task
  belongs_to :game, foreign_key: :model_id

  def view_name
    self.game&.name
  end


  def h5_link
    path = case game.type
           when 'Game::Egg'
             'golden'
           when 'Game::Wheel'
             'luck_wheel'
           when 'Game::Scratch'
             'scratch_card'
           when 'Game::Tiger'
             'tiger'
           end
    "#{Settings.h5_url}/pages/game/#{path}?id=#{self.id}"
  end

end
