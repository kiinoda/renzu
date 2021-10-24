require "sentry"

sentry = Sentry::ProcessRunner.new(
  display_name: "Kemal Dev",
  build_command: "crystal build ./src/renzu.cr -o ./bin/renzu",
  run_command: "./bin/renzu",
  files: ["./src/**/*.cr", "./src/**/*.ecr", "./src/**/*.yml"]
)
sentry.run
