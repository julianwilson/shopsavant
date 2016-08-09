Rails.application.routes.draw do
  get 'collections', to: 'collections#index'
  get 'collections/scan', to: 'collections#scan'
  get 'collections/:collection/products', to: 'products#index'
  get 'collections/:collection/products/scan', to: 'products#scan'
  get 'products/:product_handle/sales', to: 'sales#index'
end
