use Mix.Config

if :test == Mix.env() do
  config :phoenix, :json_library, Jason
end
