# This is a Sinatra application. To run the application, navigate Terminal to this directory and run
#   $ rackup
# The `rackup` command runs the three lines of that file which first tells the computer to look for
# gems, Ruby's libraries, and then to load up the contents of this file and then run a Sinatra Application
# It is this file that describes the actions of the application.

# The following two lines use `bundler` which is a program that packages up the gems specified for this
# application and makes them available. The gems are listed in the `Gemfile` file.
require 'bundler'
Bundler.require

# Now we call setup on DataMapper which is how we interface with the database.
# DataMapper is an Object Relational Mapper which allows tables of a database to be treated as
# objects, with methods and properties. ORMs convert the Ruby code into SQL.
DataMapper.setup(:default,  ENV['DATABASE_URL'] || 'sqlite:///Users/sklise/ITP/Understanding_Networks/FloorNoise/NoiseLevelCollector/Understanding.sqlite')

# Define the data class for the sound readings.
# This will correspond to a table in the database titled "reading"
# with columns matching each property declared.
class Reading
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :time, DateTime
  property :noise, Integer
  property :room, String
end

# Here we define the paths available to the application.
# This is the root. When a user goes to the root we query
# the db for the last ten Readings and then return the template
# `main` which is located in `/views/main.erb`.
get "/" do
  @readings = Reading.all(:order => [:id.desc], :limit => 10)
  erb :visualization
end

# This is the path that the Arduino is posting its data to.
# This route is declared with `:room` which is a Ruby symbol
# that matches any content and saves it to the `params` hash
# as `params[:room]`.
post "/:room/" do
  # The Arduino is posting data in the form of 
  #   noise=120,130,140,12,215,255,319...
  # Which is avaialable in `params` as `params[:noise]`.

  # millis between readings
  interval = 1000

  # We need to split the string of noise readings into integers
  @readings = params[:noise].split(',')
  # The readings are the last 30 seconds counting back from the
  # moment of the http request. So let's get the current time
  @now = Time.now

  # We are expecting 30 readings, but just to make sure
  r_length = @readings.length

  # Logging to Terminal
  puts @now
  puts ""
  puts "\e[0;34m#{params[:room]}\e[m"

  # now loop through each element of the `@readings` array
  # And save it as a new row in the database
  @readings.each_with_index do |r,i|
    reading = Reading.new({:time => @now-(r_length-i)*interval/1000.to_i, :room => params[:room], :noise => r})
    puts "  #{reading.time}"
    puts "  #{reading.noise}"

    if reading.save
      puts "  \e[0;32msuccess\e[m"
    else
      puts "  \e[0;34mfailed\e[m"
    end
    puts ""
  end
  ""
end
