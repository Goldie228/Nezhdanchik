
Rails.application.routes.draw do
  mount_avo
  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get "menu" => "categories#index", as: :menu
  get "menu/:slug" => "dishes#index", as: :category_dishes
  get "more_dishes/:slug" => "dishes#load_more", as: :load_more_dishes
end
