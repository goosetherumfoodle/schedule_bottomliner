Rails.application.routes.draw do
  get 'wakeup', to: 'wakeup#show'

  resources :inbounds, only: :create
end
