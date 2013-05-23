require 'sinatra'

configure do

  #set(:css_dir) File.join(assets/vendor/css, 'css')
  set :sessions, true
  set :public_folder, 'public/assets'
end


get '/' do
  erb :welcome, :layout => :application
end

post '/game' do
  @username =params[:username]
  erb :game, :layout => :application
end

get '/welcome/:name' do
  erb :welcome, :layout => :application
end

