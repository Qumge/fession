class UserViewLog < ApplicationRecord
  belongs_to :user
  belongs_to :viewer, class_name: 'User', foreign_key: :view_id
end
