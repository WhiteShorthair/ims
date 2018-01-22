class Track
	def initialize(title, artist)
		@title = title
		@artist = artist
    @artist_id = ""
		@number = ""
		@played_time = nil
	end

  attr_accessor :number
  attr_accessor :title
  attr_accessor :artist
  attr_accessor :artist_id
  attr_accessor :played_time

	def ==(other)
		self.class == other.class and 
		other.title == @title and
		other.artist == @artist
	end

	alias eql? ==

	def to_s()
		return "Track Number: #{@number}\nTitle: #{@title}\nArtist: #{@artist} (id: #{artist_id})\nLast Played Time: #{@played_time}"
	end

  # set track number of this track
  def set_track_num(track_num)
    @number = track_num
  end

  # play this track and set played time
  def play
    @played_time = Time.now
  end
	
end
