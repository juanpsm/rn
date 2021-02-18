json.extract! book, :id, :name, :is_default, :user_id, :created_at, :updated_at
json.url book_url(book, format: :json)
