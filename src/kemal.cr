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
    output = ""
    op.cmds.each do |command|
      parts = Deployer.get_parts(command)
      command = Deployer.normalize_command(command, parts, env.params.url)
      output += Deployer.runner(command)
    end
    output
  end
end

[404, 500].each do |e|
  error e do
    "Go away!"
  end
end
Kemal.run