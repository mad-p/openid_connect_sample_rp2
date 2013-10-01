ConnectRp::Application.routes.draw do
  resources :providers, only: :create do
    resource :open_id, only: [:show, :create]
  end
  resource :account, only: :show
  resource :session, only: :destroy

  root 'top#index'
end
