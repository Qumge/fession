# == Schema Information
#
# Table name: articles
#
#  id               :bigint           not null, primary key
#  content          :text(65535)
#  deleted_at       :datetime
#  product_view_num :integer          default(0)
#  subject          :string(255)
#  view_num         :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :integer
#  product_id       :integer
#
# Indexes
#
#  index_articles_on_deleted_at  (deleted_at)
#

class Article < ApplicationRecord
  belongs_to :article
  belongs_to :company
  belongs_to :product
  has_one :task_article_task, :class_name => 'Task::ArticleTask'


  def set_view_num
    self.update view_num: self.view_num + 1
  end
end
