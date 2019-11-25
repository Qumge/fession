# == Schema Information
#
# Table name: roles
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ApplicationRecord
  has_many :operators
  has_many :resources
  validates_presence_of :name
  validates_uniqueness_of :name

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
