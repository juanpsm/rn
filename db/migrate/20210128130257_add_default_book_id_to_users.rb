class AddDefaultBookIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :default_book_id, :integer
  end
end
