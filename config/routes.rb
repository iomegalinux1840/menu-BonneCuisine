# Define constraints inline to avoid autoloading issues
class SubdomainConstraint
  def self.matches?(request)
    # For localhost, we need to manually extract the subdomain
    subdomain = if request.host.include?('.localhost')
      request.host.split('.').first
    else
      request.subdomain
    end

    Rails.logger.debug "SubdomainConstraint checking: subdomain='#{subdomain}', host='#{request.host}'"
    return false if subdomain.blank? || subdomain == 'localhost'

    reserved = %w[www admin api app assets help support docs]
    result = !reserved.include?(subdomain)
    Rails.logger.debug "SubdomainConstraint result: #{result}"
    result
  end
end

class AdminSubdomainConstraint
  def self.matches?(request)
    request.subdomain == 'admin'
  end
end

class NoSubdomainConstraint
  def self.matches?(request)
    request.subdomain.blank? || request.subdomain == 'www'
  end
end

Rails.application.routes.draw do
  # Mount ActionCable for all domains
  mount ActionCable.server => '/cable'

  # Active Storage routes for file uploads
  # This is required for direct uploads to work
  # mount ActiveStorage::Engine => '/rails/active_storage'

  # Check for Railway environment (multi-tenant routing)
  if ENV['RAILWAY_ENVIRONMENT'].present? || ENV['RAILS_ENV'] == 'production'
    # Root shows list of restaurants
    root 'landing#index'

    # Debug route to check restaurants
    get 'debug/restaurants', to: 'debug#restaurants'

    # Restaurant-specific public menu routes
    get 'r/:restaurant_slug', to: 'public_menus#index', as: :restaurant_menu
    get 'r/:restaurant_slug/menu', to: 'public_menus#index'

    # Restaurant-specific admin routes
    get 'r/:restaurant_slug/admin', to: redirect('/r/%{restaurant_slug}/admin/login')
    get 'r/:restaurant_slug/admin/login', to: 'admin/sessions#new', as: :restaurant_admin_login
    post 'r/:restaurant_slug/admin/login', to: 'admin/sessions#create'
    delete 'r/:restaurant_slug/admin/logout', to: 'admin/sessions#destroy', as: :restaurant_admin_logout

    scope 'r/:restaurant_slug/admin', as: :restaurant_admin do
      resources :menu_items, controller: 'admin/menu_items' do
        member do
          patch :toggle_availability
        end
      end
      resources :settings, controller: 'admin/settings', only: [:index, :update]
      resources :admins, controller: 'admin/admins'
    end

    # Legacy admin route redirects to restaurant list
    get 'admin', to: redirect('/')
    get 'admin/login', to: redirect('/')

    # Create new restaurant
    resources :restaurants, only: [:new, :create] do
      member do
        get :setup
        patch :complete_setup
      end
    end
  else
    # Original complex routing for local development
    # Restaurant subdomain routes (e.g., restaurant-a.menuplatform.app)
    constraints SubdomainConstraint do
      root 'public_menus#index', as: :restaurant_menu
      # Add more restaurant-specific public routes here if needed
    end

    # Admin subdomain routes (e.g., admin.menuplatform.app)
    constraints AdminSubdomainConstraint do
      root 'admin/dashboard#index', as: :admin_root

      scope '/:restaurant_slug' do
        get 'login', to: 'admin/sessions#new', as: :admin_login
        post 'login', to: 'admin/sessions#create'
        delete 'logout', to: 'admin/sessions#destroy', as: :admin_logout

        # Admin routes scoped by restaurant
        namespace :admin do
          resources :menu_items do
            member do
              patch :toggle_availability
            end
          end
          resources :settings, only: [:index, :update]
          resources :admins
        end
      end
    end

    # Main domain routes (no subdomain or www)
    constraints NoSubdomainConstraint do
      root 'landing#index', as: :main_root

      # Debug route to check restaurants
      get 'debug/restaurants', to: 'debug#restaurants'

      # Path-based restaurant access (e.g., menuplatform.app/r/restaurant-slug)
      get 'r/:restaurant_slug', to: 'public_menus#index', as: :restaurant_path

      # Restaurant signup and onboarding
      resources :restaurants, only: [:new, :create] do
        member do
          get :setup
          patch :complete_setup
        end
      end

      # Legacy routes for backward compatibility (temporary)
      # These will use the default restaurant (La Bonne Cuisine)
      get 'menu', to: redirect('/r/la-bonne-cuisine')

      namespace :admin do
        get 'login', to: redirect('/admin/la-bonne-cuisine/login')
        post 'login', to: 'sessions#create_legacy'
        delete 'logout', to: 'sessions#destroy_legacy'

        resources :menu_items do
          member do
            patch :toggle_availability
          end
        end
      end
    end

    # Catch-all route for custom domains
    # This will be handled by CurrentTenant concern
    constraints lambda { |req| !req.subdomain.present? || req.subdomain == 'www' } do
      # Custom domain routes will fall through to here
      # The CurrentTenant concern will detect the custom domain
      root 'public_menus#index', as: :custom_domain_root
    end
  end
end