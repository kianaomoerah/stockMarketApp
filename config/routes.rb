Rails.application.routes.draw do
  root 'home#index'
  get 'home/about'
  post '/' => 'home#index'
end
