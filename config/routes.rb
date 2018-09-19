Rails.application.routes.draw do
  get 'wakeup', to: 'wakeup#create'

  resources :inbounds, only: :create
end
