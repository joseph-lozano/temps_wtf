defmodule TempsWTF.Plug.GoogleAnalytics do
  import Plug.Conn

  def init(opts) do
    case Application.get_env(:temps_wtf, :google_analytics_id) do
      nil -> opts
      ga_id -> Keyword.put(opts, :google_analytics_id, ga_id)
    end
  end

  def call(conn, google_analytics_id: ga_id), do: assign(conn, :google_analytics_id, ga_id)
  def call(conn, _), do: conn
end
