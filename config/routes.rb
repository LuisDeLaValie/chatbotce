Rails.application.routes.draw do
  mount Spree::Core::Engine, at: '/'

  resources :questions, only: [:create, :index]
end
