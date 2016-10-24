defmodule Roman.Router do
  use Roman.Web, :router

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

  scope "/", Roman do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    # users
    get "/register", UserController, :new
    post "/register", UserController, :create

    # sessions
    get "/login", SessionController, :new
    post "/login", SessionController, :create
  end

  scope "/api", Roman do
    pipe_through :api

    post "/register", Api.AuthController, :register
    post "/login", Api.AuthController, :login
    resources "/topics", Api.TopicController, except: [:new, :edit]
    resources "/posts", Api.PostController, except: [:new, :edit]
  end
end
