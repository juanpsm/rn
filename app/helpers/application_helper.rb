module ApplicationHelper
  # Renderiza el avatar de un usuario resolviendo las tres fuentes posibles
  # (foto subida, Gravatar, inicial del mail) en un solo lugar, para que el
  # sidebar y la página de cuenta no se desincronicen.
  #
  # `size` son píxeles CSS; a la variante y a Gravatar se les pide el doble
  # para que no se vean borrosos en pantallas de alta densidad.
  def user_avatar_tag(user, size: 34, css_class: nil)
    classes = ["user-avatar", css_class].compact.join(" ")
    style = "width: #{size}px; height: #{size}px;"

    case user.avatar_source
    when :upload
      image_tag user.avatar.variant(resize_to_fill: [size * 2, size * 2]),
                class: classes, style: style, alt: "", loading: "lazy"
    when :gravatar
      image_tag user.gravatar_url(size: size * 2),
                class: classes, style: style, alt: "", loading: "lazy"
    else
      tag.span user.avatar_initial,
               class: "#{classes} user-initial", style: style,
               aria: { hidden: true }
    end
  end
end
