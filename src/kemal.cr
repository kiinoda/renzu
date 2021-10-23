require "kemal"
require "yaml"
require "./utils"

Kemal.config.powered_by_header = false

class Action
  include YAML::Serializable
  @[YAML::Field(key: "route")]
  property route : String
  @[YAML::Field(key: "commands")]
  property commands : Array(String)
end

actions = Array(Action).from_yaml(File.read("./src/actions.yml"))

actions.each do |action|
  get action.route do |env|
    if !Utils.has_safe_segments(env.params.url)
      halt env, status_code: 400, response: "Invalid data provided."
    end
    action.commands.each do |command|
      segments = Utils.get_segments(command)
      command = Utils.normalize_command(command, segments, env.params.url)

      cmd, args = command.split[0], command.split[1..]

      # if client hangs up, we don't want an error hence the begin...rescue block
      begin
        Process.run(cmd, args) do |proc|
          while line = proc.output.gets || proc.error.gets
            env.response.puts line
            env.response.flush
          end
        end
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
    "Go away!"
  end
end

Kemal.run