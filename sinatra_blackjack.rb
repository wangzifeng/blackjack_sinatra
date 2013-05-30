# coding: utf-8
require 'sinatra'

before do
  @show_hit_or_stay = true
  #result(cal(session[:player]),"Player")
  @show_dealer_hit_or_stay = false
end

helpers do
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
    if total > 21 
      @error = "#{player} Busted!"
      @show_hit_or_stay = false
    elsif total == 21
      @sucess = "#{player} is BlackJack" 
      @show_hit_or_stay = false
    end
  end

  def showcard(deck)

    suit = case deck[0]
      when "S" then "spades"
      when "H" then "hearts"
      when "D" then "diamonds"
      when "C" then "clubs"
    end

    card = case deck[1]
      when "J" then "jack"
      when "Q" then "queen"
      when "K" then "king"
      when "A" then "ace"
       else
        card = deck[1]
    end

    "<img src='images/cards/#{suit}_#{card}.jpg' class='card'>"
  end

  def hide_card()
  end
end

def initial_game
  suits = ["S", "H", "D", "C"]
  cards = [2,3,4,5,6,7,8,9,10,"J","Q","K","A"]
  session[:deck] = suits.product(cards).shuffle!

  #Set Time
  session[:time] = Time.new.strftime("%m/%d/%Y")

  #Setup dealer deck
  session[:dealer] = []
  session[:player] = []

  session[:dealer] << session[:deck].pop
  session[:player] << session[:deck].pop
  session[:dealer] << session[:deck].pop
  session[:player] << session[:deck].pop

  #Count total point

end

def player_hand
  session[:player] << session[:deck].pop
end

def dealer_hand
  session[:dealer] << session[:deck].pop
end



configure do

  #set(:css_dir) File.join(assets/vendor/css, 'css')
  set :sessions, true
  set :public_folder, 'public/assets'
end

#Main Page
#If detect user session redirect to new game
#otherwise redirect new game

get '/bet' do

  erb :bet, :layout => :application
end

post '/bet' do
  session[:bet] = params[:bet_amount].to_i
  redirect '/game'
  erb :bet, :layout => :application
end

get '/' do  
  erb :welcome, :layout => :application
end

get '/new_player' do

  session[:bank] = 500

  #Set initial Bank
  erb :newplayer, :layout => :application
end

post '/new_player' do
  #Save the username of session
  if params[:username].empty? 
    @error = "Player Name is required"
    half erb(:game)
  end

  session[:username] = params[:username]
  redirect '/bet'
  erb :newplayer, :layout => :application
end

get '/game' do
  #Set up deck
  initial_game
  #redirect '/playerhand'
  erb :game, :layout => :application
end

post '/game' do
  erb :game, :layout => :application
end


get '/playerhand' do
  if cal(session[:player]) == 21
    @sucess = "Player hit BlackJack!"
    @show_hit_or_stay = false
    session[:bank] += session[:bet]
  elsif cal(session[:player]) > 21
    @error = "Player Busted!"
    @show_hit_or_stay = false
    session[:bank] -= session[:bet]
  end
  erb :game, :layout => false
end

post '/playerhand' do
  player_hand
  redirect '/playerhand'
  erb :game, :layout => false
end



post '/playerstay' do
  #@show_hit_or_stay = false
  redirect '/dealerturn'
  erb :game, :layout => :application
end

get '/dealerturn' do
  @show_hit_or_stay = false
  @show_dealer_hit_or_stay = true
  if cal(session[:dealer]) == 21
    @error = "Dealer hit BlackJack!"
    @show_hit_or_stay = false
    @show_dealer_hit_or_stay = false
    session[:bank] -= session[:bet]
  elsif cal(session[:dealer]) > 21
    @sucess = "Dealer Busted!"
    @show_hit_or_stay = false
    @show_dealer_hit_or_stay = false
    session[:bank] += session[:bet]
  elsif cal(session[:dealer]) >= 17
    redirect '/compare'
  end
  erb :game, :layout => :application
end

post '/dealerturn' do
  dealer_hand
  redirect '/dealerturn'
  erb :game, :layout => :application
end


get '/compare' do
  @show_dealer_hit_or_stay = true
  if cal(session[:dealer]) > cal(session[:player])
    @error = "Dealer Wins"
    @show_dealer_hit_or_stay = false
    session[:bank] -= session[:bet]
  elsif cal(session[:dealer]) < cal(session[:player])
    @sucess = "Player Wins"
    @show_dealer_hit_or_stay = false
    @show_hit_or_stay = false
    session[:bank] += session[:bet]
  end
  erb :game, :layout => :application
end
