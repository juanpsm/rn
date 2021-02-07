class Book < ApplicationRecord
  belongs_to :user
  has_many :notes
  validates :name, presence: true
  after_destroy :ensure_default_book_remains

  class Error < StandardError
  end

  protected #or private whatever you need

      #Raise an error that you trap in your controller to prevent your record being deleted.
        def ensure_default_book_remains
          if is_default
          raise Error.new "Can't delete default book"
        end
      end
end
