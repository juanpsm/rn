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

// Misma lista que valida User en el servidor. Antes se aceptaba cualquier
// `image/*`, que dejaba pasar SVG: no es explotable al cargarlo en un <img>
// (los navegadores no ejecutan scripts ahí), pero el servidor lo iba a
// rechazar igual, así que conviene avisar antes de abrir el recorte.
const ACCEPTED_TYPES = ["image/jpeg", "image/png", "image/webp"]

// Tope del lado largo de la copia de trabajo. El recorte final sale en
// OUTPUT_SIZE, así que no hace falta decodificar una foto de 8000px entera: es
// memoria del navegador desperdiciada.
const MAX_WORKING_SIZE = 1600

// Decodifica la imagen y la vuelve a codificar desde un canvas. Rechaza (con
// throw) cualquier archivo que el navegador no pueda decodificar como imagen.
async function decodeToCanvasBlob(file) {
  const bitmap = await createImageBitmap(file)

  const scale = Math.min(1, MAX_WORKING_SIZE / Math.max(bitmap.width, bitmap.height))
  const canvas = document.createElement("canvas")
  canvas.width = Math.round(bitmap.width * scale)
  canvas.height = Math.round(bitmap.height * scale)
  canvas.getContext("2d").drawImage(bitmap, 0, 0, canvas.width, canvas.height)
  bitmap.close()

  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => (blob ? resolve(blob) : reject(new Error("no se pudo codificar la imagen"))),
      "image/png"
    )
  })
}

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

  input.addEventListener("change", async () => {
    const file = input.files && input.files[0]
    if (!file || !ACCEPTED_TYPES.includes(file.type)) {
      input.value = ""
      return
    }

    cleanup()
    confirmed = false

    // La previsualización no se arma con los bytes del archivo, sino con los
    // píxeles ya decodificados y vueltos a codificar por nosotros:
    //
    //   1. `createImageBitmap` decodifica de verdad la imagen, así que un
    //      archivo que no sea una imagen raster válida (texto renombrado a
    //      .png, un SVG, un polyglot) falla acá y no llega a mostrarse.
    //   2. Al re-codificar desde el canvas se descarta todo lo que no sean
    //      píxeles: metadatos EXIF, comentarios y cualquier carga útil
    //      embebida en el archivo original.
    //
    // El servidor valida lo mismo por su cuenta leyendo los magic bytes; esto
    // no lo reemplaza, evita mostrar en pantalla contenido sin decodificar.
    let source
    try {
      source = await decodeToCanvasBlob(file)
    } catch {
      input.value = ""
      return
    }

    objectUrl = URL.createObjectURL(source)
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
