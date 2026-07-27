Rails.application.routes.draw do
  # `config.exceptions_app` (ver config/application.rb) despacha las excepciones
  # a estas rutas usando el código de estado como path. No debe existir un
  # `public/404.html` (etc.), porque ActionDispatch::Static lo serviría antes
  # de llegar acá y siempre con status 200.
  match "/404", to: "errors#not_found", via: :all, as: 'my_not_found'
  match "/422", to: "errors#unprocessable_entity", via: :all, as: 'my_unprocessable_entity'
  match "/500", to: "errors#internal_server_error", via: :all, as: 'my_internal_server_error'
  resources :notes
  resources :books
  devise_for :users
  root to: "home#index"
  
  get 'notes/:id/pdf', to: 'notes#download', as: 'note_download'
  get 'notes_download', to: 'notes#download_all', as: 'notes_download_all'
  get 'notes_download_separately', to: 'notes#download_all_separately'
  get 'book/:id/download_all_notes', to: 'notes#download_all_notes_from_book', as: 'download_all_notes_from_book'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
