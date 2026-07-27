// AdminLTE 4 incluye un gestor de color mode: si no encuentra una preferencia
// guardada en localStorage bajo la clave `lte-theme`, sigue la del sistema
// operativo y puede arrancar la app en modo oscuro, pisando el
// `data-bs-theme` que trae el layout.
//
// Los estilos de esta app asumen tema claro: los inputs de `.field` fuerzan
// `bg-light`, y `bg-lime` y `bg-primary` tienen el color de texto fijo. En
// oscuro eso queda inconsistente, así que se fija la preferencia en "light".
//
// Este módulo se importa ANTES que admin-lte en el pack. No alcanza con poner
// la línea arriba de todo en application.js: los `import` se hoistean y se
// evalúan antes que cualquier sentencia suelta del archivo.
//
// Para habilitar el modo automático (claro/oscuro según el sistema), borrar
// este archivo y su import, y revisar los estilos mencionados arriba.
try {
  window.localStorage.setItem("lte-theme", "light")
} catch {
  // localStorage puede no estar disponible (modo privado, cookies bloqueadas).
  // En ese caso AdminLTE cae en la preferencia del sistema, que es aceptable.
}
