class AddIsDefaultToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :is_default, :boolean
  end
end
