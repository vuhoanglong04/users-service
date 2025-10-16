Rails.application.routes.draw do
  devise_for :users, path: "api/v1/auth", skip: [:unlocks], controllers: {
    sessions: 'api/v1/auth/sessions',
    registrations: 'api/v1/auth/registrations',
    passwords: 'api/v1/auth/passwords',
    confirmations: 'api/v1/auth/confirmations',
    unlocks: 'api/v1/auth/unlocks',
    omniauth_callbacks: 'api/v1/auth/omniauth_callbacks'
  }
  devise_scope :user do
    namespace :api do
      namespace :v1 do
        namespace :auth do
          post "refresh", to: "sessions#refresh"

          post "confirm_email", to: "confirmations#confirm_email"
          post "resend_confirmation", to: "confirmations#resend_confirmation_instructions"

          post "reset_password", to: "passwords#create"
          patch "reset_password", to: "passwords#update_password"

          post "send_unlock", to: "unlocks#send_unlock"
          post "resend_unlock", to: "unlocks#resend_unlock"
          post "unlock", to: "unlocks#unlock"
        end
        namespace :admin do
          resources :users do
            member do
              post :restore
            end
          end
          resources :patients
          resources :doctors
          resources :posts do
            member do
              post :restore
            end
          end
        end
      end
    end
  end
end
