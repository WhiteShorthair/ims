require_relative "processor"

class Interpreter

	def initialize(*args)
    @input = ""
		@processor = Processor.new(args[0] ||= "store.yml")
		@key_method_table = {
			"help" => "help",
			"exit" => "exit_ims",
      "info" => "info",
      "add" => "add",
      "play" => "play",
      "count" => "count",
      "list" => "list"
		}
    @error_msg = ""
    @runnable = true
	end

  attr_accessor :input
	attr_accessor :processor
  attr_reader :key_method_table
  attr_accessor :error_msg
  attr_accessor :runnable

  # Extract first word in input to check if it is valid command and execute it
	def interpret(user_input)
    @error_msg = ""
    @input = user_input
		command = user_input.split(' ').first.downcase

    # if input is valid command return result or request user to input again
    if @key_method_table.has_key? command then instance_eval(@key_method_table[command])
    else @error_msg = "Not an available command, please input available command or use 'Help' to get a list of commands." end

    # return runnable and error message
    return @runnable, @error_msg
	end

  # interpret input with "help"
  def help
    @processor.help
  end

  # interpret input with "exit"
  def exit_ims
    @processor.save_state
    @runnable = false
  end

  # interpret input with "info"
  def info
    # get the information category
    category = @input.split(' ')[1]
    case category
    when nil, ""
      # display a high level summary of the state
      @processor.display_info
    when "track"
      if track_info = (@input.match /info track (?<track_num>\d+)/) 
        @processor.display_track_info(track_info[:track_num])
      else @error_msg = "[ERROR] Please input valid track number!" end
    when "artist"
      if artist_info = (@input.match /info artist (?<artist_id>.+)/) 
        @processor.display_artist_info(artist_info[:artist_id])
      else @error_msg = "[ERROR] Please input valid artist id!" end
    else
      @error_msg = "Not an available command, please input available command or use 'Help' to get a list of commands." 
    end
  end

  # interpret input with "add"
  def add
    category = @input.split(' ')[1]
    case category
    when "track"
      if track_info = (@input.match /add track (?<track_title>.+) by (?<artist_id>.+)/) 
        @processor.add_track(track_info[:track_title], track_info[:artist_id])
      else @error_msg = "[ERROR] Please confirm track title and artist id!" end
    when "artist"
      if artist_info = (@input.match /add artist (?<artist_name>.+)/) 
        @processor.add_artist(artist_info[:artist_name])
      else @error_msg = "[ERROR] Please input artist name!" end
    else 
      @error_msg = "Not an available command, please input available command or use 'Help' to get a list of commands." 
    end
  end

  # interpret input with "play" to play track
  def play
    if track_info = (@input.match /play track (?<track_num>\d+)/) 
      @processor.play_track(track_info[:track_num])
    else @error_msg = "[ERROR] Please input valid track number!" end
  end

  # interpret input with "count" to count tracks by particular artist
  def count
    if artist_info = (@input.match /count tracks by (?<artist_id>.+)/) 
      @processor.display_track_count(artist_info[:artist_id])
    else @error_msg = "[ERROR] Please input valid artist id!" end
  end

  # interpret input with "list" to list all tracks by particular artist
  def list
    if track_info = (@input.match /list tracks by (?<artist_id>.+)/) 
      @processor.list_track(track_info[:artist_id])
    else @error_msg = "[ERROR] Please input valid artist id!" end
  end

end

