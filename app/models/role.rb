# == Schema Information
#
# Table name: roles
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_roles_on_deleted_at  (deleted_at)
#

class Role < ApplicationRecord
  has_many :operators
  has_and_belongs_to_many :resources, join_table: 'role_resources'
  validates_presence_of :name
  validates_uniqueness_of :name
  acts_as_paranoid
  class << self
    def search_conn params
      roles = self.all
      roles = roles.where('name like ?', "%#{params[:search]}%") if params[:search].present?
      roles
    end
  end

  def operator_amount
    operators.size
  end

end
