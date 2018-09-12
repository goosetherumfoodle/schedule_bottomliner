Rails.application.routes.draw do
  resources :inbounds, only: :create
end
