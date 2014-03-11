include Mongo
require 'sinatra/base'

class AtHome < Sinatra::Base

configure do
  conn = MongoClient.new("localhost", 27017)
  set :mongo_connection, conn
  set :mongo_db, conn.db('athome')
end

helpers do
  # a helper method to turn a string ID
  # representation into a BSON::ObjectId
  def object_id val
    BSON::ObjectId.from_string(val)
  end

  def document_by_id id
    id = object_id(id) if String === id
    settings.mongo_db['athome'].
      find_one(:_id => id).to_json
  end
end

get '/' do
  content_type :json
  settings.mongo_db['athome'].find.to_a.to_json
end

post '/register' do
  content_type :json

  doc = {"uid" => params[:uid], "username" => params[:username], "bid" => params[:bid], "type" => params[:type], "date" => Time.now}

  new_id = settings.mongo_db['athome'].insert doc
  '{"success": "ok"}'
end


get '/remove/?' do
  settings.mongo_db['athome'].remove(:_id => object_id(params[:id]))
end

get '/find/?' do
  content_type :json

  settings.mongo_db['athome'].aggregate([
    {"$sort" => {"date" => - 1}},
    {"$group" => {_id: {uid: "$uid"}, date: {"$first" => "$date"}, type: {"$first" => "$type"}, username: {"$first" => "$username"}, bid: {"$first" => "$bid"}}},
    {"$match" => {bid: {"$eq" => params[:bid]}}}
  ]).to_a.to_json


end

end


