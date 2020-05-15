Rails.application.routes.draw do
  root to: "welcome#index"
  get "/oauth2-callback", to: "welcome#oauthcallback"
end
