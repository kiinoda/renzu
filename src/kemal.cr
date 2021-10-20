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

      cmd = command.split[0]
      args = command.split[1..]
      stdout = IO::Memory.new
      process = Process.new(cmd, args, output: stdout, error: stdout)
      status = process.wait
      output += process.pid.to_s
      output += stdout.to_s
    end
    output
  end
end

# get "/deploy/:setup/branch/:branch" do |env|
#   setup = env.params.url["setup"]
#   branch = env.params.url["branch"]
#   # "Deploy #{setup} on branch #{branch}"
#   output = ""
#   ["sleep 20", "echo Hello! 100"].each do |p|
#     cmd = p.split[0]
#     args = p.split[1..]
#     stdout = IO::Memory.new
#     process = Process.new(cmd, args, output: stdout)
#     status = process.wait
#     output += stdout.to_s
#   end
#   output
# end

# get "/sleep/:time/say/:word" do |env|
#   time = env.params.url["time"]
#   word = env.params.url["word"]
#   output = ""
#   ["sleep #{time}", "echo #{word}"].each do |p|
#     cmd = p.split[0]
#     args = p.split[1..]
#     stdout = IO::Memory.new
#     process = Process.new(cmd, args, output: stdout)
#     status = process.wait
#     if cmd == "sleep"
#       output += "Slept #{time} seconds. "
#     else
#       output += stdout.to_s
#     end
#   end
#   output
# end

[404, 500].each do |e|
  error e do
    "Go away!"
  end
end
Kemal.run