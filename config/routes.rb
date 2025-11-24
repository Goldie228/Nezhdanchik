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

  get "reservation", to: "reservations#show", as: :reservation
  get "reservation/check_availability", to: "reservations#check_availability", as: :check_reservation_availability
  get "reservation/time_slots", to: "reservations#time_slots", as: :reservation_time_slots
  get "reservation/check_seat_availability", to: "reservations#check_seat_availability", as: :check_seat_availability
  post "reservation", to: "reservations#create", as: :create_reservation
  get "reservation/:id", to: "reservations#details", as: :reservation_details
  patch "reservation/:id", to: "reservations#update", as: :update_reservation
  delete "reservation/:id", to: "reservations#cancel", as: :cancel_reservation

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

  get "cart", to: "cart#show", as: :cart
  get "cart/info/:dish_id", to: "cart#cart_info", as: :cart_info
  post "cart/add/:dish_id", to: "cart#add", as: :add_to_cart
  post "cart/increase/:dish_id", to: "cart#increase", as: :increase_cart_item
  post "cart/decrease/:dish_id", to: "cart#decrease", as: :decrease_cart_item
  patch "cart/update/:id", to: "cart#update", as: :update_cart_item
  delete "cart/remove/:id", to: "cart#remove", as: :remove_cart_item
  delete "cart/clear", to: "cart#clear", as: :clear_cart

  # Форс мажорные пути
  get "orders/history", to: "orders#history"

  get "manager/dashboard", to: "manager#dashboard"
  post "manager/update_status", to: "manager#update_status"

  get "privacy_policy", to: "pages#privacy_policy"
  get "terms_of_use", to: "pages#terms_of_use"
end
