Rails.application.routes.draw do
  devise_for :users
  devise_for :customers
  devise_for :admins
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount ApplicationAPI => '/api'
  mount GrapeSwaggerRails::Engine => '/apidoc'
end
