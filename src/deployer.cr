class Deployer

  # extract only those parts from the command which begin with semicolon
  def self.get_segments(command : String)
    # extract them from the command line
    segments = command.split.select { |seg| seg[0] == ':' }
    # return them to the user without the semicolons
    return segments.map { |seg| seg[1..]}
  end

  # replace segments in command with their values from the matching route
  def self.normalize_command(command : String, segments : Array(String), values : Hash)
    segments.each do |seg|
      command = command.sub(":#{seg}", values[seg])
    end
    return command
  end

end