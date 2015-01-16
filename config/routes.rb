Rails.application.routes.draw do
  ACCEPT_HEADER = "application/vnd.shorthanded+json; version=1"

  namespace :api do
    api_version(
      module: "V1",
      header: { name: "Accept", value: ACCEPT_HEADER },
      defaults: { format: :json }
    ) do
      resources :apps, only: [:create]
    end
  end
end
