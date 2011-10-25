require 'bundler'
Bundler.require
require 'socket'

DataMapper.setup(:default,  ENV['DATABASE_URL'] || 'sqlite:///Users/sklise/ITP/Understanding_Networks/FloorNoise/NoiseLevelCollector/Understanding.sqlite')

class Reading
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :time, DateTime
  property :noise, Integer
  property :room, String
end

class SavedValues
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :contents, Text
end

get "/" do
  @readings = Reading.all(:order => [:id.desc], :limit => 10)
  erb :main
end

get "/:room/:date.:format" do
  # :date => 20111019 (YYYYMMDD)
  @readings = Reading.all({
    :time.gt => params[:date].to_i-1,
    :time.lt => params[:date].to_i+1,
    :room => params[:room]
  })
  full_response = []
  @readings.each do |r|
    params[:format] == "json" ? single_response = {} : single_response = ""
    r.attributes.each do |k,v|
      params[:format] == "json" ? single_response[k] = v : single_response += "#{v},"
    end
    full_response << ((params[:format] == "json") ? single_response.to_json : single_response)
  end
  params[:format] == "json" ? "{"+full_response.join(",")+"}" : full_response.join("\n")
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

  # if Time.now.hour >= 9-3 && Time.now <= 23
    puts "\e[0;34m#{params[:room]}\e[m"
    @readings.each_with_index do |r,i|
      reading = Reading.new(:time => @now-(r_length-i)*interval/1000.to_i, :room => params[:room], :noise => r)
      puts "  #{reading.time}"
      puts "  #{reading.noise}"
    
      if reading.save
        puts "  \e[0;32msuccess\e[m"
      else
        puts "  \e[0;34mfailed\e[m"
      end
      puts ""
    end
  # end
  ""
end