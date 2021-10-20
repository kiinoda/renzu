class Deployer
  # extract only those parts from the command which begin with semicolon
  def self.get_parts(command : String)
    prefixed = command.split.reject do |part|
      part[0] != ':'
    end
    unprefixed = prefixed.map do |part|
      part[1..]
    end
  end

  # normalize command passed in via yaml with values from URL/route
  def self.normalize_command(command : String, parts : Array(String), substitutions : Hash)
    parts.each do |p|
      command = command.sub(":#{p}", substitutions[p])
    end
    command
  end
end