require 'bundler'
Bundler.require

DataMapper.setup(:default,  ENV['DATABASE_URL'] || 'sqlite:///Users/sklise/ITP/Understanding Networks/FloorNoise/NoiseApp/data.db')

get "/" do
  @readings = Reading.all(:order => [:id.desc], :limit => 10)
  erb :main
end

get "/:room/:start_time/:n_readings" do
  content_type :json
  readings = Reading.all({
    :limit => params["n_readings"].to_i,
    :room => params["room"],
    :time.gt => params["start_time"]
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
  # params = :noise, :room, :time?
  r = Reading.new(:time => Time.now, :room => params[:room], :noise => params[:noise])
  if r.save
    output = "success"
  else
    output = "failed"
  end
  output
end

class Reading
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :time, Time
  property :noise, Integer
  property :room, String
end