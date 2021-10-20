class Deployer
  # extract only those parts from the command which begin with semicolon
  def self.get_parts(command : String)
    prefixed = command.split.reject do |part|
      part[0] != ':'
    end
    unprefixed = prefixed.map do |part|
      part[1..]
    end
    return unprefixed
  end

  # normalize command passed in via yaml with values from URL/route
  def self.normalize_command(command : String, parts : Array(String), substitutions : Hash)
    parts.each do |p|
      command = command.sub(":#{p}", substitutions[p])
    end
    return command
  end

  def self.runner(command : String)
    cmd = command.split[0]
    args = command.split[1..]
    stdout = IO::Memory.new
    process = Process.new(cmd, args, output: stdout, error: stdout)
    status = process.wait
    return output
  end
end