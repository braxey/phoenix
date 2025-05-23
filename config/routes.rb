Rails.application.routes.draw do
  # Health check.
  get "up" => "rails/health#show", as: :rails_health_check

  # Landing page.
  root "pages#home"

  # Dashboards.
  get "dashboard", to: "pages#dashboard"

  # Auth.
  get "login", to: "sessions#new", as: :new_session
  resource :session, except: %i[ new ]
  resources :passwords, param: :token, except: %i[ index show destroy ]

  # Registration / Account management.
  get "signup", to: "users#new", as: :new_user
  resource :users, only: %i[ create ]

  namespace :settings do
    resource :profile, only: %i[ show update destroy ]
    resource :password, only: %i[ show update ]
  end

  resources :notifications, only: :index do
    member do
      patch :mark_as_read
    end
  end

  # Roles / Permissions.
  resources :roles, except: :show
  resources :permissions
  resources :roles_permissions, only: [ :create, :destroy ]

  # Organizations.
  resources :organizations do
    # Manage users within organizations.
    resources :organization_memberships, only: %i[ index edit update destroy ]
    resources :organization_invitations, param: :token do
      member do
        patch :handle_invitation_response
      end
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
