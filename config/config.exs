# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :temps_wtf,
  namespace: TempsWTF,
  ecto_repos: [TempsWTF.Repo]

# Configures the endpoint
config :temps_wtf, TempsWTFWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Esz1acVZCiG9H3jqHlXF9zTjY5lDLSnPIsZvsh5v3xTixMoGbDEd3aNgYeC54fwm",
  render_errors: [view: TempsWTFWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TempsWTF.PubSub,
  live_view: [signing_salt: "GzxhEp6y"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
