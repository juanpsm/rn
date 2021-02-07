class Note < ApplicationRecord
  belongs_to :book
  has_rich_text :content
  validates :title, presence: true
end
