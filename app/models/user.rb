require "digest"

class User < ApplicationRecord
  AVATAR_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  AVATAR_MAX_SIZE = 2.megabytes

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :books
  has_many :notes, through: :books
  has_one_attached :avatar
  after_create :create_default_notebook

  # Sólo existe para que el checkbox de "quitar foto" tenga a qué atarse; el
  # purge lo hace ProfilePhotosController, no una callback del modelo.
  attr_accessor :remove_avatar

  validate :avatar_is_a_reasonable_image, if: -> { avatar.attached? }

  def create_default_notebook
    @user = User.last
    @book = @user.books.create(name: "#{@user.email.split(/@/)[0]}'s notebook", is_default: true)
    @user.default_book_id = @book.id
    @user.save
  end

  # De dónde sale el avatar a mostrar, en orden de prioridad: la foto propia
  # gana; después el Gravatar, sólo si el usuario lo pidió explícitamente; y si
  # no, la inicial del mail.
  def avatar_source
    return :upload if avatar.attached?
    return :gravatar if use_gravatar?

    :initial
  end

  # Gravatar acepta SHA256 además del viejo MD5, y pide normalizar el mail
  # (minúsculas, sin espacios) antes de hashearlo. `d=mp` es la silueta
  # genérica, para los mails que no tienen cuenta.
  def gravatar_url(size: 80)
    hash = Digest::SHA256.hexdigest(email.to_s.strip.downcase)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=mp"
  end

  def avatar_initial
    email.to_s.strip.first.to_s.upcase
  end

  private

  # Se validan tipo y tamaño a mano en lugar de sumar la gema
  # active_storage_validations: son dos reglas y no justifican otra dependencia.
  #
  # El tipo se determina leyendo los bytes del archivo, no el `content_type`
  # que declaró el cliente. ActiveStorage guarda la declaración del cliente:
  # le pasa a Marcel el tipo declarado como pista, y Marcel la respeta. Un
  # archivo de texto subido como "image/png" quedaba almacenado como imagen y
  # pasaba esta validación.
  def avatar_is_a_reasonable_image
    if avatar.byte_size > AVATAR_MAX_SIZE
      errors.add(:avatar, "must be smaller than #{AVATAR_MAX_SIZE / 1.megabyte} MB")
    end

    # Sólo hay que analizar el archivo cuando se está adjuntando uno nuevo; si
    # no, cada save del usuario releería el blob de más.
    io = incoming_avatar_io
    return if io.nil?

    # Sin `declared_type` ni `name`: que decida únicamente por los magic bytes.
    unless AVATAR_CONTENT_TYPES.include?(Marcel::MimeType.for(io))
      errors.add(:avatar, "must be a JPEG, PNG or WebP image")
    end
  ensure
    io.rewind if io.respond_to?(:rewind)
  end

  # El io original del archivo que se está adjuntando en este save. Sale de
  # `attachment_changes` porque durante la validación el blob todavía no se
  # subió al servicio y no se puede abrir.
  def incoming_avatar_io
    attachable = attachment_changes["avatar"]&.attachable
    return if attachable.nil?

    case attachable
    when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
      attachable.tempfile
    when Hash
      attachable[:io]
    when File, Tempfile
      attachable
    end
  end
end
