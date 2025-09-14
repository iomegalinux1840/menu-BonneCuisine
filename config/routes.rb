Rails.application.routes.draw do
  root 'menu_items#index'

  namespace :admin do
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'

    resources :menu_items do
      member do
        patch :toggle_availability
      end
    end
  end

  mount ActionCable.server => '/cable'
end