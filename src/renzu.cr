require "kemal"
require "yaml"
require "./utils"

Kemal.config.port = (ENV["PORT"]? || 8192).to_i
Kemal.config.host_binding = ENV["HOST_BINDING"]? || "127.0.0.1"
Kemal.config.env = "production"
Kemal.config.powered_by_header = false

APP_CONFIG = ENV["CONFIG"]? || "actions.yml"

class Action
  include YAML::Serializable
  @[YAML::Field(key: "route")]
  property route : String
  @[YAML::Field(key: "commands")]
  property commands : Array(String)
end

actions, err = Utils.load_yaml(APP_CONFIG)
if nil != err
  abort(err)
end

actions.each do |action|
  get action.route do |env|
    if !Utils.has_safe_segments(env.params.url)
      halt env, status_code: 400, response: "Invalid data provided."
    end
    action.commands.each do |command|
      segments = Utils.get_segments(env.params.url)
      command = Utils.normalize_command(command, segments, env.params.url)

      # if client hangs up, we don't want an error hence the begin...rescue block
      begin
        output = `#{command}`
        env.response.puts output
        env.response.flush
      rescue HTTP::Server::ClientError
        Log.error {"Client hung up before we completed."}
      rescue ex : IO::Error
        Log.error {"IO::Error, #{ex}"}
      end
    end # rescue block
  end # get route
end # route configurator

[404, 500].each do |e|
  error e do
    ""
  end
end

Kemal.run
