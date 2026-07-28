// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
// Bootstrap 5 y AdminLTE 4 no dependen de jQuery, así que se importan como
// módulos y no hace falta exponer globales.
import * as bootstrap from "bootstrap"
// Debe ir antes de admin-lte: fija el color mode antes de que su gestor corra.
import "../color_mode"
import "admin-lte"
import "../stylesheets/application.scss"
// FontAwesome se carga una sola vez, como webfont desde stylesheets/application.scss.
// Antes también se importaba acá `@fortawesome/fontawesome-free/js/all`, que es
// la variante SVG+JS: reemplaza cada <i> del documento por un <svg> mediante un
// MutationObserver. Además de duplicar la librería, esa sustitución deja nodos
// detached y hacía fallar de forma intermitente los tests de sistema con
// "Node with given id does not belong to the document".
import "../avatar_cropper"

document.addEventListener("turbolinks:load", () => {
  // En Bootstrap 5 los tooltips siguen siendo opt-in, pero se inicializan por
  // API en vez de con el plugin de jQuery.
  document.querySelectorAll('[data-bs-toggle="tooltip"]')
    .forEach(el => new bootstrap.Tooltip(el))
})

Rails.start()
Turbolinks.start()
ActiveStorage.start()

require("trix")
require("@rails/actiontext")
