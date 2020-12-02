module RN
  autoload :VERSION, 'rn/version'
  autoload :Commands, 'rn/commands'
  autoload :Note, 'rn/model/note'
  autoload :Book, 'rn/model/book'
  autoload :FileManager, 'rn/helpers/file_manager'
  autoload :Editor, 'rn/helpers/editor'
  autoload :Exporter, 'rn/helpers/exporter'
  autoload :RougeeHelper, 'rn/helpers/rougee_helper'

  # Agregar aquí cualquier autoload que sea necesario para que se cargue las clases y
  # módulos del modelo de datos.
  # Por ejemplo:
  # autoload :Note, 'rn/note'
end
