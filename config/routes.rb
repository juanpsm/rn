Rails.application.routes.draw do
  match "/404", to: "errors#not_found", via: :all, as: 'my_not_found'
  match "/500", to: "errors#internal_server_error", via: :all, as: 'my_internal_server_error'
  resources :notes
  resources :books
  devise_for :users
  root to: "home#index"
  
  get 'notes/:id/pdf', to: 'notes#download', as: 'note_download'
  get 'notes_download', to: 'notes#download_all'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

end
