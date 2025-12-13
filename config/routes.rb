Rails.application.routes.draw do
  constraints AdminConstraint.new do
    mount Avo::Engine => "/admin"
  end

  root "pages#home"
  get  "up",        to: "rails/health#show", as: :rails_health_check

  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest",       to: "rails/pwa#manifest",       as: :pwa_manifest

  get "menu",              to: "categories#index", as: :menu
  get "menu/:slug",        to: "dishes#index",     as: :category_dishes
  get "menu/:slug/order",  to: "dishes#show",      as: :dish
  get "more_dishes/:slug", to: "dishes#load_more", as: :load_more_dishes

  get "reservation",                         to: "reservations#show",                    as: :reservation
  get "reservation/check_availability",      to: "reservations#check_availability",      as: :check_reservation_availability
  get "reservation/time_slots",              to: "reservations#time_slots",              as: :reservation_time_slots
  get "reservation/check_seat_availability", to: "reservations#check_seat_availability", as: :check_seat_availability
  post "reservation",                        to: "reservations#create",                  as: :create_reservation
  get "reservation/:id",                     to: "reservations#details",                 as: :reservation_details
  patch "reservation/:id",                   to: "reservations#update",                  as: :update_reservation
  delete "reservation/:id",                  to: "reservations#cancel",                  as: :cancel_reservation

  get "profile",   to: "users#show", as: :profile
  patch "profile", to: "users#update"

  post "change_email",     to: "users#change_email"
  post "change_password",  to: "users#change_password"
  delete "delete_account", to: "users#destroy"

  get "signup",  to: "users#new"
  post "signup", to: "users#create"

  get "login",      to: "sessions#new",     as: :login
  post "login",     to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  get "two_factor",              to: "two_factor#show",   as: :email_verification
  post "two_factor",             to: "two_factor#create"
  post "two_factor/resend",      to: "two_factor#resend", as: :resend_two_factor
  get "two_factor/verification", to: "two_factor#verification"

  get "email/confirmation",   to: "email#confirmation",  as: :email_confirmation
  post "email/change_status", to: "email#change_status", as: :change_status
  get "email/confirm/:token", to: "email#confirm",       as: :confirm_email

  get "password/change",         to: "password#change",            as: :password_change
  patch "password/update",       to: "password#update"
  get "password/forgot",         to: "password#forgot",            as: :password_forgot
  post "password/forgot",        to: "password#create_reset_token"
  get "password/reset/:token",   to: "password#reset",             as: :password_reset
  patch "password/reset/:token", to: "password#update_by_token"
  get "password/success",        to: "password#success"

  get "cart",                    to: "cart#show",      as: :cart
  get "cart/info/:dish_id",      to: "cart#cart_info", as: :cart_info
  post "cart/add/:dish_id",      to: "cart#add",       as: :add_to_cart
  post "cart/increase/:dish_id", to: "cart#increase",  as: :increase_cart_item
  post "cart/decrease/:dish_id", to: "cart#decrease",  as: :decrease_cart_item
  patch "cart/update/:id",       to: "cart#update",    as: :update_cart_item
  delete "cart/remove/:id",      to: "cart#remove",    as: :remove_cart_item
  delete "cart/clear",           to: "cart#clear",     as: :clear_cart

  get "orders/history",     to: "orders#history", as: :orders_history
  get "orders/:id",         to: "orders#show",    as: :order
  post "orders/:id/repeat", to: "orders#repeat",  as: :repeat_order

  get "manager",                                                  to: "manager#dashboard",         as: :manager
  get "manager/dashboard",                                        to: "manager#dashboard"
  get "manager/calendar",                                         to: "manager#calendar",          as: :manager_calendar
  get "manager/tables",                                           to: "manager#tables_view",       as: :manager_tables
  get "manager/bookings",                                         to: "manager#bookings",          as: :manager_bookings
  get "manager/bookings/:id",                                     to: "manager#show",              as: :manager_booking
  get "manager/bookings/:id/edit",                                to: "manager#edit",              as: :edit_manager_booking
  get "manager/dishes_by_category",                               to: "manager#dishes_by_category"
  get "manager/order_item/:id",                                   to: "manager#order_item"
  post "manager/bookings/:id/add_dish_to_order",                  to: "manager#add_dish_to_order"
  patch "manager/bookings/:id/update_order_item/:order_item_id",  to: "manager#update_order_item"
  delete "manager/bookings/:id/remove_order_item/:order_item_id", to: "manager#remove_order_item"
  patch "manager/bookings/:id",                                   to: "manager#update"
  delete "manager/bookings/:id",                                  to: "manager#destroy"
  post "manager/update_status",                                   to: "manager#update_status"
  get "manager/refresh_orders",                                   to: "manager#refresh_orders",    as: :manager_refresh_orders

  get "privacy_policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms_of_use",   to: "pages#terms_of_use",   as: :terms_of_use
end
