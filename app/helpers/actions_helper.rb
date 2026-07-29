# Vocabulario único para las acciones sobre un registro.
#
# Antes cada vista inventaba el suyo para las mismas operaciones:
#
#   notes/index (barra)   botones sólidos, tres colores distintos, sin texto
#   notes/_note (tarjeta) dropdown con items de texto: Show / Edit / Destroy
#   books/index (tabla)   el mismo dropdown de texto
#   notes/show            botones de ícono `btn-sm btn-outline-*` con tooltip
#   books/show            los mismos, pero en otro orden
#
# Cuatro gramáticas para cuatro verbos. Acá se define una sola: cada acción
# tiene un ícono y un color, y significan lo mismo en toda la aplicación.
module ActionsHelper
  ACTIONS = {
    show: { icon: "fas fa-eye", variant: "primary", label: "Show" },
    edit: { icon: "fas fa-pencil-alt", variant: "warning", label: "Edit" },
    destroy: { icon: "far fa-trash-alt", variant: "danger", label: "Delete" },
    pdf: { icon: "fas fa-file-pdf", variant: "primary", label: "View as PDF" },
    download: { icon: "fas fa-download", variant: "primary", label: "Download PDF" },
    archive: { icon: "fas fa-file-archive", variant: "primary", label: "Download ZIP" }
  }.freeze

  # Un botón de ícono. El texto va en `title` (tooltip) y en `aria-label`, para
  # que la acción no dependa de poder ver el ícono.
  def action_button(kind, path, label: nil, confirm: nil, method: nil)
    spec = ACTIONS.fetch(kind)
    text = label || spec[:label]

    link_to path,
            class: "btn btn-sm btn-outline-#{spec[:variant]}",
            title: text,
            "aria-label": text,
            method: method,
            data: { "bs-toggle": "tooltip", "bs-placement": "bottom", confirm: confirm }.compact do
      tag.i(class: spec[:icon], "aria-hidden": true)
    end
  end

  # El alta es la única acción que lleva texto: es la principal de cada
  # pantalla y conviene que se lea, no que haya que adivinarla por el ícono.
  def add_button(path, label, title: nil)
    link_to path, class: "btn btn-sm bg-accent btn-inline-icon", title: title || label do
      safe_join([tag.i(class: "fas fa-plus", "aria-hidden": true), label], " ")
    end
  end

  # Agrupa botones con una separación pareja. Sin esto cada vista dependía del
  # espacio en blanco del ERB, que Bootstrap 5 ya no compensa (en la v4 los
  # botones traían margen propio).
  def record_actions(&block)
    tag.div(capture(&block), class: "record-actions")
  end
end
