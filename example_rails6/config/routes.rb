Rails.application.routes.draw do
  get '/styleguide', to: 'styleguide#index'
  get '/demo-form', to: 'styleguide#demo_form'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
