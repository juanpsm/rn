class Note < ApplicationRecord
  belongs_to :book
  has_rich_text :content
  validates :title, presence: true, uniqueness: { scope: :book,
    message: "of note already exists in this book" }
end
