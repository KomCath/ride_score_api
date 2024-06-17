Rails.application.routes.draw do
  namespace :v1 do
    scope ":driver_id" do
      resources :assignments, only: [:index]
    end

    resources :addresses
  end
end
