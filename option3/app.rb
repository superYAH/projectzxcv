require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'

DB = Mongo::Connection.new.db("mydb", :pool_size => 5, :timeout => 5)

enable :sessions 

get '/' do
  "Hello World! I'm sexy and I know it as :D"
  #haml :index, :attr_wrapper => '"', :locals => {:title => 'haii'}
end

get '/shit' do
  halt "WFT !?"  
  #haml :index, :attr_wrapper => '"', :locals => {:title => 'haii'}
end

get '/event' do
  # Get All events
  events = db.collection('events')
  erb :layout
end

get '/event/:id' do
  # Get Single event
 pass unless params[:id] == '1'
  event_id = params[:id]
  event = events.find( :id => event_id ).first 
  "Never gonna give you up, never gonna let you down #{event[:text]}"
end

post '/eventI' do
  # Insert Event
    newEvent = {  
      :text => 'Remember the milk',  
      :name => 'Party ZONE'}  
    event_id = events.insert(newEvent)  
end

put '/event/:id' do
  # Get Single event
end

delete '/event/:id' do
  # Get Single event
end

get '/todo' do
  redirect '/'
  #haml :todo, :attr_wrapper => '"', :locals => {:title => 'MongoDB Backed TODO App'}
end

get '/api/:thing' do
  DB.collection(params[:thing]).find.to_a.map{|t| from_bson_id(t)}.to_json
end

get '/api/:thing/:id' do
  from_bson_id(DB.collection(params[:thing]).find_one(to_bson_id(params[:id]))).to_json
end

post '/api/:thing' do
  oid = DB.collection(params[:thing]).insert(JSON.parse(request.body.read.to_s))
  "{\"_id\": \"#{oid.to_s}\"}"
end

delete '/api/:thing/:id' do
  DB.collection(params[:thing]).remove('_id' => to_bson_id(params[:id]))
end

put '/api/:thing/:id' do
  DB.collection(params[:thing]).update({'_id' => to_bson_id(params[:id])}, {'$set' => JSON.parse(request.body.read.to_s).reject{|k,v| k == '_id'}})
end

def to_bson_id(id) BSON::ObjectId.from_string(id) end
def from_bson_id(obj) obj.merge({'_id' => obj['_id'].to_s}) end