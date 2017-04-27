defmodule HookLineAndSlacker.WebhookListener do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: HookLineAndSlacker.port)
  end

  get "/zz/health" do
    body = %{
      status: :ok,
      version: HookLineAndSlacker.version,
    }
    conn
    |> send_resp(200, Poison.encode!(body))
    |> halt
  end

  post "/callbacks/github" do
    case conn.body_params do
      %{"action" => "submitted", "pull_request" => %{"url" => url, "title" => title }} ->
        IO.inspect(url)
        IO.inspect(title)
      _ -> :ok
    end
    send_resp(conn, 204, "")
  end

  match _ do
    conn
    |> send_resp(404, "Nothing here")
    |> halt
  end
end
