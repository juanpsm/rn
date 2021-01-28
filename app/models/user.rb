class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :books
  has_many :notes, through: :books
  after_create :create_default_notebook

  def create_default_notebook
    @user = User.last
    @book = @user.books.create(name: "#{@user.email.split(/@/)[0]}'s notebook", is_default: true)
    @user.default_book_id = @book.id
    @user.save
  end
end
