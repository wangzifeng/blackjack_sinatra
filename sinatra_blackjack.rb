# coding: utf-8
require 'sinatra'

def cal(cards)
    arr = cards.map { |v| v[1]}
    total = 0
    arr.each do |v|
      if v == "A"
        total += 11
      elsif v.to_i == 0
        total += 10
      else
        total += v.to_i
      end
    end

    arr.select { |x| x == "A"}.count.times do
      total -= 10 if total > 21
    end
    total
end


def result(total, player)
  "Total point #{total}"
  if total > 21 
    "#{player} Busted!"
  elsif total == 21
    "#{player} is BlackJack" 
  end
end

def initial_game
  suits = ["S", "H", "D", "C"]
  cards = [2,3,4,5,6,7,8,9,10,"J","Q","K","A"]
  session[:deck] = suits.product(cards).shuffle!

  #Set Time
  session[:time] = Time.new

  #Set initial Bank value
  session[:ante] = 3000

  #Set initial Ante
  session[:ante] = 10

  #Setup dealer deck
  session[:dealer] = []
  session[:player] = []

  session[:dealer] << session[:deck].pop
  session[:player] << session[:deck].pop
  session[:dealer] << session[:deck].pop
  session[:player] << session[:deck].pop

  #Count total point

  session[:dealer_total] = cal(session[:dealer])
  session[:player_total] = cal(session[:player])
 
  session[:dealer_result] = result(session[:dealer_total],session[:dealer])
  session[:player_result] = result(session[:player_total],session[:player])

end


def player_hand
  session[:player] << session[:deck].pop
  session[:player_total] = cal(session[:player])
  session[:player_result] = result(session[:player_total],session[:player])
  session[:player_result]
end

def dealer_hand
  session[:dealer] << session[:deck].pop
  session[:dealer_total] = cal(session[:dealer])
end

configure do

  #set(:css_dir) File.join(assets/vendor/css, 'css')
  set :sessions, true
  set :public_folder, 'public/assets'
end

#Main Page
#If detect user session redirect to new game
#otherwise redirect new game
get '/' do
  if session[:username]
    redirect '/game'
  else
    redirect '/new_player'
  end
  erb :welcome, :layout => :application
end

get '/new_player' do
  redirect '/game'
  erb :newplayer, :layout => :application
end

post '/new_player' do
  session[:username] = params[:username]
  erb :newplayer, :layout => :application
end

get '/game' do
  #Set up deck
  if session[:player_result]
    initial_game
  end

  erb :game, :layout => :application
end

post '/game' do
  erb :game, :layout => :application
end

post '/playerhand' do
  player_hand
  redirect '/game'
end
