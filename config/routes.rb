Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  scope '(:locale)', locale: /en|de/ do
    devise_for :user, controllers: {confirmations: 'user/confirmations',
                                    passwords:     'user/passwords',
                                    registrations: 'user/registrations',
                                    sessions:      'user/sessions',
                                    unlocks:       'user/unlocks'}

    devise_scope :user do
      get :user, to: 'user/registrations#show', as: nil # Helper user_registration_path is already generated by Devise (as POST, but seems to be OK for GET, too)
    end

    resources :users
    resources :pages
    resources :projects
    resources :customers
    resources :timetracks

    [403, 404, 422, 500].each do |code|
      get code, to: 'errors#show', code: code
    end

    root 'homepage#show'

    # The priority is based upon order of creation: first created -> highest priority.
    # See how all your routes lay out with "rake routes".

    # Example of regular route:
    #   get 'products/:id' => 'catalog#view'

    # Example of named route that can be invoked with purchase_url(id: product.id)
    #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

    # Example resource route (maps HTTP verbs to controller actions automatically):
    #   resources :products

    # Example resource route with options:
    #   resources :products do
    #     user do
    #       get 'short'
    #       post 'toggle'
    #     end
    #
    #     collection do
    #       get 'sold'
    #     end
    #   end

    # Example resource route with sub-resources:
    #   resources :products do
    #     resources :comments, :sales
    #     resource :seller
    #   end

    # Example resource route with more complex sub-resources:
    #   resources :products do
    #     resources :comments
    #     resources :sales do
    #       get 'recent', on: :collection
    #     end
    #   end

    # Example resource route with concerns:
    #   concern :toggleable do
    #     post 'toggle'
    #   end
    #   resources :posts, concerns: :toggleable
    #   resources :photos, concerns: :toggleable

    # Example resource route within a namespace:
    #   namespace :admin do
    #     # Directs /admin/products/* to Admin::ProductsController
    #     # (app/controllers/admin/products_controller.rb)
    #     resources :products
    #   end
  end
end
