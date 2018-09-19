Rails.application.routes.draw do
  post 'wakeup', to: 'wakeup#create'

  resources :inbounds, only: :create
end
