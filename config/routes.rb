Local::Application.routes.draw do

  root :to => "home#index"
  get "/alert_config", :to =>"settings#alert_config"
  post "/update_alert_config", :to =>"settings#update_alert_config"
  get "/settings/templates", :to => "settings#template_config"
  post "/settings/templates", :to => "settings#update_template_config"

  resources :custom_messages

  resources :users do
    collection do
      get "validate"
    end
  end

  resources :places do
    collection do
      get "import"
      post "upload_csv"
      post "confirm_import"
    end

    resources :users
  end

  resources :thresholds

  resources :sessions, :only =>[:new,:create,:destroy] do
    collection do
      get "signin"
      get "signout"
    end
  end

  match  '/contact' => "page#contact"
  match  '/about' => "page#about"
  match  "/signup" => "users#new"
  match  "/user_edit/:id" => "users#user_edit"
  match  "/user_update" => "users#user_save"
  match  "/user_cancel/:id" => "users#user_cancel"


  match "/nuntium/receive_at" => "nuntium#receive_at"

  match ':controller(/:action(/:id(.:format)))'
end
