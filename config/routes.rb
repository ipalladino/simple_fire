D2mECards::Application.routes.draw do

  get "sessions/new"
  get "sessions/login"
  resources :sessions
  
  match '/login_form', :to => 'pages#login_form'

  get "ecards/json_list"
  resources :ecards

  get "ecard_orders/new"

  get "sent_ecards/new"

  get "senders/new"

  resources :users
  root :to => 'pages#app'
  
  match '/checkout', :to =>  'pages#checkout'
  match '/requestmessages', :to =>  'ecard_orders#requestmessages'
  match '/view/ecard', :to =>  'ecard_orders#viewecard'
  match '/contact', :to =>  'pages#contact'
  match '/app', :to =>  'pages#app'
  match '/testnewapp', :to =>  'pages#testnewapp'
  match '/getproducts', :to => 'pages#getproducts'
  match '/do_special_request', :to => 'pages#do_special_request'
  match '/addtocart', :to => 'pages#addtocart'
  match '/paywithpaypal', :to => 'pages#paywithpaypal'
  match '/viewcookie', :to => 'pages#viewcookie'
  match '/support', :to => 'pages#support'
  match '/support_request_sent', :to => 'pages#support_request_sent'
  
  
  match '/view_ecard_mobile', :to => 'ecard_orders#view_ecard_mobile'
  match '/transaction', :to => 'pages#transaction'
  match '/transactionsuccess', :to => 'ecard_orders#transactionsuccess'
  match '/handleorder', :to => 'ecard_orders#handleorder'
  match '/redeemcode', :to => 'ecard_orders#redeemcode'
  match '/autoredeem', :to => 'ecard_orders#autoredeem'
  
  
  
  
  
  #map.resources :sessions
  #map.login 'login', :controller => 'sessions', :action => 'new'
  #map.logout 'logout', :controller => 'sessions', :action => 'destroy'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
