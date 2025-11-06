
Rails.application.routes.draw do
  constraints AdminConstraint.new do
    mount Avo::Engine => "/admin"
  end

  root "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get "menu" => "categories#index", as: :menu
  get "menu/:slug" => "dishes#index", as: :category_dishes
  get "menu/:slug/order" => "dishes#show", as: :dish
  get "more_dishes/:slug" => "dishes#load_more", as: :load_more_dishes

  get "reservations/new", to: "reservations#new", as: :new_reservation

  get "profile", to: "users#show", as: :profile
  patch "profile", to: "users#update"

  post "change_email", to: "users#change_email"
  post "change_password", to: "users#change_password"
  delete "delete_account", to: "users#destroy"

  get "signup", to: "users#new"
  post "signup", to: "users#create"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  get "two_factor", to: "two_factor#show", as: :email_verification
  post "two_factor", to: "two_factor#create"
  post "two_factor/resend", to: "two_factor#resend", as: :resend_two_factor
  get "two_factor/verification", to: "two_factor#verification"

  get "email/confirmation", to: "email#confirmation", as: :email_confirmation
  post "email/change_status", to: "email#change_status", as: :change_status
  get "email/confirm/:token", to: "email#confirm", as: :confirm_email

  get "password/change", to: "password#change", as: :password_change
  patch "password/update", to: "password#update"
  get "password/forgot", to: "password#forgot", as: :password_forgot
  post "password/forgot", to: "password#create_reset_token"
  get "password/reset/:token", to: "password#reset", as: :password_reset
  patch "password/reset/:token", to: "password#update_by_token"
  get "password/success", to: "password#success"

  # Форс мажорные пути

  get "orders/history", to: "orders#history"

  get "manager/dashboard", to: "manager#dashboard"
  post "manager/update_status", to: "manager#update_status"

  get "privacy_policy", to: "pages#privacy_policy"
  get "terms_of_use", to: "pages#terms_of_use"

  get "cart", to: "cart#show"
  post "cart/add", to: "cart#add"
  patch "cart/update", to: "cart#update"
  delete "cart/remove", to: "cart#remove"
  delete "cart/clear", to: "cart#clear"
end
