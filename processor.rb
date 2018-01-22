# require "pstore"
require "yaml/store"
require_relative "track"
require_relative "artist"

class Processor

	def initialize(filename)
		@store = YAML::Store.new(filename)
		@track_list = @store.transaction { @store.fetch(:tracks, Hash.new) }
		@artist_list = @store.transaction { @store.fetch(:artists, Hash.new) }
		@last_played = @store.transaction { @store.fetch(:last_played, Array.new) }
		@command = ""
	end

	attr_accessor :store
	attr_accessor :track_list
	attr_accessor :artist_list
	attr_accessor :last_played
	attr_accessor :command

	# output of command 'Help'
	# display a list of commands
	def help
		help_introduction = "\tHelp - display available commands
	Exit - save state of artist and track then exit
	Info - display a high level summary of the state
	Info track - display info about a certain track by number
	Info artist - display info about a certain artist, by id
	Add Artist - add a new artist to storage. e.g. add artist john osborne
	Add Track - add a new track to storage. e.g. add track watching the sky turn green by jo
	Play Track - record that an existing track was played at the current time. e.g. play track 13
	Count tracks - display how many tracks are known by a certain artist. e.g. count tracks by jo
	List tracks - display the tracks played by a certain artist. e.g. list tracks by jo"
		puts help_introduction
	end

	# save the state of all tracks and artists
	def save_state
		@store.transaction do 
			@store[:tracks] = @track_list
			@store[:artists] = @artist_list
			@store[:last_played] = @last_played
		end
	end

	# diplay the info in a high level summary
	def display_info
		puts "Total track number: #{@track_list.length}"
		puts "Total artist number: #{@artist_list.length}"
		puts "Last three played track:"
		@last_played.each do |last_played_track|
      puts "------------ Track Info -------------"
			puts "#{last_played_track.to_s}"
		end
	end

	# add new track
	def add_track(title, artist)
		# check if artist exists if not create artist first
		id = ""
		tmp_artist = Artist.new(id, artist)
		if @artist_list.has_value? tmp_artist then id = @artist_list.key(tmp_artist)
		else id = add_artist(artist)
		end
		
		# create new track
		new_track = Track.new(title, artist)
		# check if this track already exists in the list
		if @track_list.has_value? new_track then puts "This track already exists in database."
		else 
			track_num = @track_list.length + 1
			new_track.number = track_num
      new_track.artist_id = id
			@track_list[track_num.to_s] = new_track

			# udpate corresponding artist track list
			@artist_list[id].add_track(new_track)
			puts "New track #{title} by #{artist} added succesfully!"
		end
	end

	# add new artist
	def add_artist(artist)
		# check if artist already exists in list and get or assign a new artist id
		id = ""
		tmp_artist = Artist.new(id, artist)

		# create new artist and assign a new id if not exist in database
		if !@artist_list.has_value? tmp_artist
			# create artist id for new artist
			id = artist.split.map(&:chr).join.downcase
      sub_id = ""
			while @artist_list.has_key? (id + sub_id.to_s)
				if sub_id != "" then sub_id += 1
        else sub_id = 1 end
			end
      id = id + sub_id.to_s

			# create a new artist
			new_artist = Artist.new(id, artist)
			# add new artist to artist list
			@artist_list[id] = new_artist
			puts "New artist #{artist} added succesfully with artist id #{id}!"
		else
			id = @artist_list.key(tmp_artist)
			puts "Artist #{artist} already exists in database!"
		end
		
		return id 
	end
	
  # display track information by particular track number
	def display_track_info(track_num)
		if @track_list.has_key? track_num.to_s then puts @track_list[track_num].to_s
		else puts "Track #{track_num} does not exist in database!" end
	end

  # display artist information by particular artist id
	def display_artist_info(artist_id)
		if @artist_list.has_key? artist_id then @artist_list[artist_id].print()
		else puts "Artist with ID #{artist_id} does not exist in database!" end
	end

  # play track and add it to last played list
	def play_track(track_num)
		# execute play for this track if trackNum exist
		if @track_list.has_key? track_num
			playing_track = @track_list[track_num]
			playing_track.play

			# add most recent played track into last played 3 track lists
			@last_played << playing_track
			if @last_played.length > 3 then @last_played.shift end
			puts "Track #{track_num} #{playing_track.title} is playing!"
		else puts "Track #{track_num} does not exist in database!" end
	end

  # display count of tracks by particular artist id
	def display_track_count(artist_id)
		if @artist_list.has_key? artist_id
			artist_info = @artist_list[artist_id]
			puts "The track count for artist #{artist_info.artist} (#{artist_info.id}) is #{artist_info.tracks.length}"
		else
			puts "Artist with ID #{artist_id} does not exist in database!"
		end
	end

  # display all tracks information of particular artist
	def list_track(artist_id)
		if @artist_list.has_key? artist_id
			artist_info = @artist_list[artist_id]
			artist_info.tracks.each do |track|
        puts "------------ Track Info -------------"
				puts track.to_s
			end
		else
			puts "Artist with ID #{artist_id} does not exist in database!"
		end
	end
end