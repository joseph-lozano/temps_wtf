defmodule TempsWTFWeb.Router do
  use TempsWTFWeb, :router
  import Plug.BasicAuth
  alias TempsWTF.Plug.GoogleAnalytics

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TempsWTFWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GoogleAnalytics
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TempsWTFWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", TempsWTFWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  pipeline :admin do
    plug :basic_auth,
      username: "admin",
      password: Application.get_env(:temps_wtf, :admin_password)
  end

  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through [:browser, :admin]
    live_dashboard "/dashboard", metrics: TempsWTFWeb.Telemetry
  end
end
