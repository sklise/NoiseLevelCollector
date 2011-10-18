require 'bundler'
Bundler.require
require 'socket'

DataMapper.setup(:default,  ENV['DATABASE_URL'] || 'sqlite:///Users/sklise/ITP/Understanding Networks/FloorNoise/NoiseApp/data.db')

class Reading
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :time, DateTime
  property :noise, Integer
  property :room, String
end

get "/" do
  @readings = Reading.all(:order => [:id.desc], :limit => 10)
  erb :main
end

get "/:room/:n_readings" do
  content_type :json
  readings = Reading.all({
    :limit => params["n_readings"].to_i,
    :room => params["room"]
  })
  full_response = []
  readings.each do |r|
    single_response = {}
    r.attributes.each do |k,v|
      single_response[k] = v
    end
    full_response << single_response.to_json
  end
  "{"+full_response.join(",")+"}"
end

post "/:room/" do
  # params = :noise, :room
  # raise params.inspect
  # params[:noise] => "120,130,140,12,215,255,319"
  @readings = params[:noise].split(',') # array of readings, ordered first to last
  @now = Time.now # times for readings will be back-dated from right now
  r_length = @readings.length # how many readings were sent?

  interval = 1000 # millis between readings

  puts @now
  puts ""

  puts "\e[0;34m#{params[:room]}\e[m"

  @readings.each_with_index do |r,i|
    reading = Reading.new(:time => @now-(r_length-i)*interval/1000, :room => params[:room], :noise => r)
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