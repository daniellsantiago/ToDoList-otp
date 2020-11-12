import Config

config :todo, :database, pool_size: 3, folder: "./persist"
config :todo, port: 5454

import_config "#{config_env()}.exs"
