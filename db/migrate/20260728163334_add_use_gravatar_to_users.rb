class AddUseGravatarToUsers < ActiveRecord::Migration[8.1]
  # Opt-in explícito: mostrar el Gravatar implica que el navegador de quien
  # visita la página le pida la imagen a un tercero (Automattic) usando un hash
  # del mail del usuario. Por eso arranca apagado.
  def change
    add_column :users, :use_gravatar, :boolean, default: false, null: false
  end
end
