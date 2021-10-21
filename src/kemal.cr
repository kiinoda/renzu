require "kemal"
require "yaml"
require "./deployer"

Kemal.config.powered_by_header = false

class Route
  include YAML::Serializable
  @[YAML::Field(key: "route")]
  property route : String
  @[YAML::Field(key: "cmds")]
  property cmds : Array(String)
end

operations = Array(Route).from_yaml(File.read("./src/config.yml"))
operations.each do |op|
  get op.route do |env|
    op.cmds.each do |command|
      parts = Deployer.get_parts(command)
      command = Deployer.normalize_command(command, parts, env.params.url)
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
        Log.error {"Client hang up before we completed."}
      rescue ex : IO::Error
        Log.error {"IO::Error, #{ex}"}
      end
    end
  end
end

[404, 500].each do |e|
  error e do
    "Go away!"
  end
end
Kemal.run