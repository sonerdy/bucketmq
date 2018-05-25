defmodule BucketMQWeb.Router do
  use BucketMQWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BucketMQWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/projects", ProjectController
  end

  # Other scopes may use custom stacks.
  # scope "/api", BucketMQWeb do
  #   pipe_through :api
  # end
end
