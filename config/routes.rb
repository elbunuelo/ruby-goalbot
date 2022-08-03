require 'resque/scheduler'
require 'resque/scheduler/server'

Rails.application.routes.draw do
  resources :team_aliases, only: [:create]
  resources :leagues, only: [:create]
  resources :subscriptions, only: [:create]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
