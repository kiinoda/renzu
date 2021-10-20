require "sentry"

sentry = Sentry::ProcessRunner.new(
  display_name: "Kemal Dev",
  build_command: "crystal build ./src/kemal.cr -o ./bin/kemal",
  run_command: "./bin/kemal",
  files: ["./src/**/*.cr", "./src/**/*.ecr", "./src/**/*.yml"]
)
sentry.run
