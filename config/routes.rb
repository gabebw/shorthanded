Rails.application.routes.draw do
  namespace :api do
    api_version(
      module: "V1",
      header: { name: "Accept", value: "application/vnd.shorthanded+json; version=1" },
      defaults: { format: :json }
    ) do
      resources :apps, only: [:create]
    end
  end
end
