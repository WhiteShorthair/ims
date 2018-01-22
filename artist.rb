class Artist
	def initialize(id, artist)
		@id = id
		@artist = artist
		@tracks = []
	end

  attr_accessor :id
  attr_accessor :artist
  attr_accessor :tracks

	def ==(other)
		self.class == other.class and
		other.artist == @artist
	end

	alias eql? ==

  def to_s()
    return "ID: #{@id}\nArtist: #{@artist}\nTracks: #{@tracks}"
  end

  # add new track to track list
  def add_track(track)
    @tracks.push(track)
  end

  # print information of this artist
  def print()
    puts "ID: #{@id}"
    puts "Artist: #{@artist}"
    puts "Tracks: "
    @tracks.each do |track|
      puts "------------ Track Info -------------"
      puts "#{track.to_s}"
    end
  end

end
