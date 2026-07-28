// Recorte del avatar antes de subirlo.
//
// El recorte se hace en el navegador y lo que viaja al servidor es la imagen
// ya cuadrada: así no hace falta un segundo paso de procesamiento ni guardar
// el original. La contra es que para re-encuadrar hay que volver a subir la
// foto, algo aceptable para un avatar.
//
// Si este módulo no carga, el input sigue siendo un campo de archivo común y
// la imagen se sube sin recortar; el servidor la acepta igual.

import Cropper from "cropperjs"
import "cropperjs/dist/cropper.css"
import { Modal } from "bootstrap"

// Lado del recorte exportado. Alcanza para el avatar de 96px en pantallas de
// alta densidad, y mantiene el archivo chico.
const OUTPUT_SIZE = 512

function setup() {
  const input = document.querySelector("[data-avatar-input]")
  const modalEl = document.getElementById("avatar-cropper")
  if (!input || !modalEl) return

  const image = modalEl.querySelector("[data-avatar-cropper-image]")
  const confirm = modalEl.querySelector("[data-avatar-cropper-confirm]")
  const modal = new Modal(modalEl)

  let cropper = null
  let objectUrl = null
  // El recorte reemplaza el contenido del input. Si el usuario cancela,
  // volvemos a dejarlo como estaba en vez de subir algo que no eligió.
  let confirmed = false

  const cleanup = () => {
    if (cropper) { cropper.destroy(); cropper = null }
    if (objectUrl) { URL.revokeObjectURL(objectUrl); objectUrl = null }
  }

  input.addEventListener("change", () => {
    const file = input.files && input.files[0]
    if (!file || !file.type.startsWith("image/")) return

    cleanup()
    confirmed = false
    objectUrl = URL.createObjectURL(file)
    image.src = objectUrl
    modal.show()
  })

  // Cropper necesita que el contenedor ya tenga tamaño, así que se inicializa
  // recién cuando el modal terminó de abrirse.
  modalEl.addEventListener("shown.bs.modal", () => {
    cropper = new Cropper(image, {
      aspectRatio: 1,
      viewMode: 1,
      autoCropArea: 1,
      background: false
    })
  })

  modalEl.addEventListener("hidden.bs.modal", () => {
    if (!confirmed) input.value = ""
    cleanup()
  })

  confirm.addEventListener("click", () => {
    if (!cropper) return

    cropper.getCroppedCanvas({
      width: OUTPUT_SIZE,
      height: OUTPUT_SIZE,
      imageSmoothingQuality: "high"
    }).toBlob((blob) => {
      if (!blob) return

      // No se puede asignar `input.files` directamente: hay que armar un
      // DataTransfer y pasarle su lista de archivos.
      const cropped = new File([blob], "avatar.png", { type: "image/png" })
      const transfer = new DataTransfer()
      transfer.items.add(cropped)
      input.files = transfer.files

      confirmed = true
      modal.hide()
    }, "image/png")
  })
}

document.addEventListener("turbolinks:load", setup)
