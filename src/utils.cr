class Utils

  def self.load_yaml(config : String)
    err = nil
    actions = [] of Action
    begin
      actions = Array(Action).from_yaml(File.read(config))
    rescue ex
      err = "Could not load YAML file."
    end
    return actions, err
  end

  # extract those parts from the route which begin with semicolon
  def self.get_segments(segments : Hash)
    segments = segments.keys.select { |v| /^[a-zA-Z0-9-._+=:^]{1,64}$/.match(v) }
    return segments
  end

  # replace segments in command with their values from the matching route
  def self.normalize_command(command : String, segments : Array(String), values : Hash)
    segments.each do |seg|
      command = command.gsub(":#{seg}", values[seg])
    end
    return command
  end

  # check sanity of segments
  def self.has_safe_segments(segments : Hash)
    # check for valid values & lengths
    invalid = segments.values.reject { |v| /^[a-zA-Z0-9-._+=:^]{1,64}$/.match(v) }
    return 0 == invalid.size
  end

end