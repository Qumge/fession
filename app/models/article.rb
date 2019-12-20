# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  content    :text(65535)
#  deleted_at :datetime
#  subject    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  product_id :integer
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
end
