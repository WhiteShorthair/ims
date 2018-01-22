require "minitest/autorun"
require "yaml/store"
require_relative "interpreter"
require_relative "processor"

describe Interpreter do

  before(:all) do
    @interpreter = Interpreter.new("test.yml")
  end

  it "can show command list with help command" do
    assert_output("\tHelp - display available commands
\tExit - save state of artist and track then exit
\tInfo - display a high level summary of the state
\tInfo track - display info about a certain track by number
\tInfo artist - display info about a certain artist, by id
\tAdd Artist - add a new artist to storage. e.g. add artist john osborne
\tAdd Track - add a new track to storage. e.g. add track watching the sky turn green by jo
\tPlay Track - record that an existing track was played at the current time. e.g. play track 13
\tCount tracks - display how many tracks are known by a vertain artist. e.g. count tracks by jo
\tList tracks - display the tracks palyed by a certain artist. e.g. list tracks by jo\n") {@interpreter.interpret("help")}
    @interpreter.runnable.must_equal true
  end

  it "can show empty database state" do
    assert_output(/Total track number: 5\nTotal artist number: 4\nLast three played track:\n/) { @interpreter.interpret("info")}
  end

  it "can show information of existing artist" do
    assert_output(/ID: jl\nArtist: Jo Lin/) {@interpreter.interpret("info artist jl")}
  end

  it "can not show information of not existing artist" do
    assert_output("Artist with ID ta does not exist in database!\n") {@interpreter.interpret("info artist ta")}
  end

  it "can not show information without inputting artist id" do
    @interpreter.interpret("info artist")
    @interpreter.error_msg = "[ERROR] Please input valid artist id!"
  end

  it "can show information of existing track" do
    assert_output(/.*Track Number: 1\nTitle: wanna wanna/) {@interpreter.interpret("info track 1")}
  end

  it "can not show information of not existing track" do
    assert_output("Track 10 does not exist in database!\n") {@interpreter.interpret("info track 10")}
  end

  it "can not show information of track withou inputting track number" do
    @interpreter.interpret("info track")
    @interpreter.error_msg = "[ERROR] Please input valid track number!"
  end

  it "can add new artist" do
    # add a new artist
    @interpreter.interpret("add artist Test A")
    @interpreter.processor.artist_list.length.must_equal 5
    @interpreter.processor.artist_list["ta"].artist.must_equal "Test A"

    # add another new artist and artist id would be assigned to a formatted one
    @interpreter.interpret("add artist Test Anna")
    @interpreter.processor.artist_list.length.must_equal 6
    @interpreter.processor.artist_list["ta1"].artist.must_equal "Test Anna"

    # use info to confirm database state
    assert_output(/Total track number: 5\nTotal artist number: 6\nLast three played track:\n/) { @interpreter.interpret("info")}

  end

  it "can not add an existing artist" do
    # add a new artist
    @interpreter.interpret("add artist Test A")
    @interpreter.processor.artist_list.length.must_equal 5
    @interpreter.processor.artist_list["ta"].artist.must_equal "Test A"

    # add an existing artist
    @interpreter.interpret("add artist Test A")
    @interpreter.processor.artist_list.length.must_equal 5
  end

  it "can not add new artist without artist name" do
    @interpreter.interpret("add artist")
    @interpreter.error_msg.must_equal "[ERROR] Please input artist name!"
  end

  it "can add new track for not existing artist" do
    # artist ta not existing in database
    assert_nil(@interpreter.processor.artist_list["ta"])

    # add artist and track to database
    @interpreter.interpret("add track track 1 by Test A")
    @interpreter.processor.track_list.length.must_equal 6
    @interpreter.processor.artist_list.length.must_equal 5

    # track has been added into the track list of artist "Test A"
    assert(@interpreter.processor.artist_list["ta"].tracks.include? Track.new("track 1", "Test A"))
  end

  it "can add new track for existing artist" do
    # add a new artist
    @interpreter.interpret("add artist Test A")
    @interpreter.processor.artist_list.length.must_equal 5
    @interpreter.processor.artist_list["ta"].tracks.length.must_equal 0

    # add new track for artist "Test A"
    @interpreter.interpret("add track track 1 by Test A")
    @interpreter.processor.track_list.length.must_equal 6
    @interpreter.processor.artist_list.length.must_equal 5

    # track has been added into the track list of artist "Test A"
    assert(@interpreter.processor.artist_list["ta"].tracks.include? Track.new("track 1", "Test A"))
  end

  it "can not add an existing track" do
    # add new track for artist "Test A"
    @interpreter.interpret("add track track 1 by Test A")
    @interpreter.processor.track_list.length.must_equal 6
    @interpreter.processor.artist_list.length.must_equal 5

    # add new track for artist "Test A"
    assert_output("This track already exists in database.\n") {
      @interpreter.interpret("add track track 1 by Test A")
    }
    @interpreter.processor.track_list.length.must_equal 6
    @interpreter.processor.artist_list.length.must_equal 5
  end

  it "can play existing track and keep last 3 played track" do
    # play existing track
    assert_output("Track 1 wanna wanna is playing!\n") {@interpreter.interpret("play track 1")}

    # played track would be added into last played list
    last_played = @interpreter.processor.last_played
    assert(last_played.include? @interpreter.processor.track_list["1"])
    last_played.length.must_equal 3
  end

  it "can not play not existing track" do
    assert_output("Track 10 does not exist in database!\n") {@interpreter.interpret("play track 10")}
  end

  it "can count tracks number of particular artist" do
    assert_output("The track count for artist Jo Lin (jl) is 2\n") {@interpreter.interpret("count tracks by jl")}

    # count tracks number for new artist
    @interpreter.interpret("add artist Test A")
    assert_output("The track count for artist Test A (ta) is 0\n") {@interpreter.interpret("count tracks by ta")}
  end

  it "can not count tracks number of not existing artist" do
    assert_output("Artist with ID ta does not exist in database!\n") {@interpreter.interpret("count tracks by ta")}
  end

  it "can list tracks information for existing artist" do
    assert_output(/.*Track Number: 1\n(.*\n)+Track Number: 2\n.*/) {@interpreter.interpret("list tracks by jl")}

    # list tracks number for new artist
    @interpreter.interpret("add artist Test A")
    assert_silent {@interpreter.interpret("list tracks by ta")}
  end

  it "can not list tracks information for not existing artist" do
    assert_output("Artist with ID ta does not exist in database!\n") {@interpreter.interpret("list tracks by ta")}
  end

  it "can not process command in invalid format" do
    # can not process info command with unnecessary word
    @interpreter.interpret("info a track or a artist")
    @interpreter.error_msg.must_equal "Not an available command, please input available command or use 'Help' to get a list of commands."

    # initialize error message
    @interpreter.error_msg = ""

    # can not process add command with unnecessary word
    @interpreter.interpret("add a new artist")
    @interpreter.error_msg.must_equal "Not an available command, please input available command or use 'Help' to get a list of commands."

    # initialize error message
    @interpreter.error_msg = ""

    # can not process command not defined in this program
    @interpreter.interpret("delete all")
    @interpreter.error_msg.must_equal "Not an available command, please input available command or use 'Help' to get a list of commands."
  end

  it "can exit" do
    @interpreter.interpret("exit")
    @interpreter.runnable.must_equal false
    assert_silent {"nothing output"}
  end

end