Rails.application.routes.draw do
  root to: 'power_generators#index'
  resources :home, only: %i[index]

  resources :power_generators, only: %i[show]
  resources :freights, only: %i[index]

  get '/test', to: 'power_generators#test'
end
