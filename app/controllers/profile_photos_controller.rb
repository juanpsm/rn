# La foto y la preferencia de Gravatar se actualizan por acá y no por el
# formulario de Devise a propósito.
#
# `Devise::RegistrationsController#update` exige la contraseña actual, que es lo
# correcto para cambiar el mail o la clave, pero sería una fricción absurda para
# cambiar una foto. Meter el avatar en ese formulario obligaría a relajar esa
# protección para todos los campos.
class ProfilePhotosController < ApplicationController
  before_action :authenticate_user!

  def update
    current_user.avatar.purge if params.dig(:user, :remove_avatar) == "1"

    if current_user.update(profile_photo_params)
      redirect_to edit_user_registration_path, notice: "Profile photo updated."
    else
      redirect_to edit_user_registration_path,
                  alert: current_user.errors.full_messages.to_sentence
    end
  end

  private

  def profile_photo_params
    params.require(:user).permit(:avatar, :use_gravatar)
  end
end
