  Rails.application.routes.draw do
    resources :applications, param: :token, only: [ :index, :show, :create, :update ] do
      resources :chats, param: :number, only: [ :index, :show, :create ] do
        resources :messages, param: :number, only: [ :index, :show, :create, :update ] do
          collection do
            get :search
          end
        end
      end
    end




  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
