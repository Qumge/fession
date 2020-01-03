# == Schema Information
#
# Table name: user_view_logs
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#  view_id    :integer
#

class UserViewLog < ApplicationRecord
  belongs_to :user
  belongs_to :viewer, class_name: 'User', foreign_key: :view_id
end
