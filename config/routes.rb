Rails.application.routes.draw do

  get "/callback", to: "oauth#callback"
  get "/authorize", to: "oauth#authorize"
  get "/deauthorize", to: "oauth#deauthorize"

  resources :nations

  resources :events
  get "/choose_site", to: "events#choose_site"
  get "/choose_event", to: "events#choose_event"
  get "/set_event", to: "events#set_event"

  get "events/cancel_event", to: "events#new_event"
  get "events/cancel_site", to: "events#new_site"
  get "sync_status", to: "events#sync_status"

  get "rsvps/cache", to: "rsvps#cache"

  resources :rsvps
  post "/rsvps/check_in", to: "rsvps#check_in"
  post "/rsvps/check_out", to: "rsvps#check_out"
  get "rsvps/new_guest", to: "rsvps#new_guest"
  get "/sync", to: "rsvps#sync"

  resources :people

  resources :user_sessions
  
  resources :users do
    member do
      get :activate
      put :confirm
    end
  end

  resources :password_resets
  get "reset", to: "password_resets#password_reset"

  get 'admin', to: 'admin#index'
  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout

  root :to => 'user_sessions#new'

end
