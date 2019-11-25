class AddColumnDeletedAtToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :deleted_at, :datetime
    add_index :admins, :deleted_at

    add_column :articles, :deleted_at, :datetime
    add_index :articles, :deleted_at

    add_column :categories, :deleted_at, :datetime
    add_index :categories, :deleted_at

    add_column :companies, :deleted_at, :datetime
    add_index :companies, :deleted_at

    add_column :games, :deleted_at, :datetime
    add_index :games, :deleted_at

    add_column :products, :deleted_at, :datetime
    add_index :products, :deleted_at

    add_column :norms, :deleted_at, :datetime
    add_index :norms, :deleted_at

    add_column :prizes, :deleted_at, :datetime
    add_index :prizes, :deleted_at

    add_column :questionnaires, :deleted_at, :datetime
    add_index :questionnaires, :deleted_at

    add_column :resources, :deleted_at, :datetime
    add_index :resources, :deleted_at

    add_column :roles, :deleted_at, :datetime
    add_index :roles, :deleted_at

    add_column :tasks, :deleted_at, :datetime
    add_index :tasks, :deleted_at

    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at
  end
end
