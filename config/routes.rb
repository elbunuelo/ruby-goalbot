require 'resque/scheduler'
require 'resque/scheduler/server'
require 'resque_web'

Rails.application.routes.draw do
  scope '(:locale)', locale: /en|es/ do
    resources :team_aliases, only: [:create]
    resources :subscriptions, only: [:create]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
