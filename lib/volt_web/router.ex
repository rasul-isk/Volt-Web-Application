defmodule VoltWeb.Router do
  use VoltWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {VoltWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NavigationHistory.Tracker

    plug VoltWeb.Authentication, repo: Volt.Repo

  end

  forward "/sent_emails", Bamboo.SentEmailViewerPlug

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VoltWeb do
    pipe_through :browser

    # resources "/password-reset", PasswordResetController, except: [:index, :show]

    resources "/password-reset", PasswordResetController, except: [:index, :show]

    get "/", PageController, :index
    # resources "/customers", CustomerController, only: [:new, :create, :show]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    # resources "/menus", MenuController
    # resources "/customer_orders", Customer_OrderController
    # resources "/carts", CartController


    get    "/login",  SessionController, :new
    post   "/login",  SessionController, :create
    delete "/logout", SessionController, :delete
    get "/register", AuthController, :index


    get    "/new-customer",  CustomerController, :new
    post   "/customer",  CustomerController, :create
    get "/customer/edit/:id", CustomerController, :edit
    post "/customer/update/:id", CustomerController, :update
    get "/customer/profile", CustomerProfileController, :index
    get "/restaurants", RestaurantlistsController, :index

    get    "/new-courier",  CourierController, :new
    post   "/courier",  CourierController, :create
    get "/courier/profile", CourierProfileController, :index
    get "/courier/edit/:id", CourierController, :edit
    post "/courier/update/:id", CourierController, :update

    get    "/new-restaurant",  RestaurantController, :new
    post   "/restaurant",  RestaurantController, :create
    get "/restaurant/profile", RestaurantProfileController, :index
    get "/restaurant/edit/:id", RestaurantController, :edit
    post "/restaurant/update/:id", RestaurantController, :update

    get "/restaurant/:id/menu", RestaurantController, :menuIndex
    get "/restaurant/edit/items/:id", RestaurantController, :edit_item
    post "/restaurant/update/item/:id", RestaurantController, :update_item
    delete "/restaurant/delete_item/:id", RestaurantController, :delete_item

    get "/restaurants/:restName", PublicRestaurantController, :index
    get "/restaurants/:restName/choose-address", PublicRestaurantController, :addressIndex
    post "/restaurants/:restName/choose-address", PublicRestaurantController, :process

    get "/restaurant/menu/:id/add-new-item", ItemController, :new
    post "/restaurant/menu/:id/add-new-item", ItemController, :create
    get "/restaurant/menu/:id/items", ItemController, :index

    post "/restaurant/menu/items", CartItemController, :create

    # get "/customer/cart", CartController, :index
    # delete "/customer/cart/:id", CartItemController, :delete

    post "/customer/order/items", OrderController, :create_order
    # get "/customer/orders", OrderController, :index

    get "/restaurant/restaurant-orders", RestaurantController, :ordersIndex
    post "/restaurant/restaurant-orders/:id", RestaurantController, :update_order_time
    post "/restaurant/restaurant-orders/mark-prepared/:id", RestaurantController, :mark_order_prepared

    get "/restaurant/restaurant-orders/show/:id", RestaurantController, :show_order

    post "/restaurant/restaurant-orders/reject/:id", RestaurantController, :reject_order
    post "/restaurant/restaurant-orders/cancel-order/:id", RestaurantController, :cancel_order

    # Courier orders
    get "/courier/available-orders/address-selection", CourierController, :address_selection
    post "/courier/available-orders/address-selection/:id", CourierController, :address_selection_process
    get "/courier/available-orders/current-address=:address", CourierController, :available_orders_index

    post "/courier/available-orders/accept-order/:id", CourierController, :accept_order
    post "/courier/available-orders/reject-order/:id", CourierController, :reject_order

    get "/customer/my-orders", CustomerController, :orders_index
    get "/restaurant/my-orders/history", RestaurantController, :orders_history
    get "/courier/my-orders", CourierController, :orders_index
    post "/courier/complete-order/:id", CourierController, :complete_order

    get "/customer/orders/:id/leave-review", CustomerController, :leave_review_index
    post "/customer/orders/leave-review", CustomerController, :leave_review
  end

  # Other scopes may use custom stacks.
  # scope "/api", VoltWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VoltWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
