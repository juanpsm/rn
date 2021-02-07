Rails.application.routes.draw do
  resources :notes
  resources :books
  devise_for :users
  root to: "home#index"
  
  get 'notes/:id/pdf', to: 'notes#download', as: 'note_download'
  get 'notes_download', to: 'notes#download_all'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

end
