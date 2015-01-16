Rails.application.routes.draw do
  accept_header = "application/vnd.shorthanded+json; version=1"

  namespace :api do
    api_version(
      module: "V1",
      header: { name: "Accept", value: accept_header },
      defaults: { format: :json }
    ) do
      resources :apps, only: [:create]
    end
  end
end
