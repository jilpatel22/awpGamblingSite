require 'dm-core'
require 'dm-migrations'

enable :sessions

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :password, String
  property :totalWins, Integer
  property :totalLoss, Integer
  property :totalProfit, Integer
end

DataMapper.finalize

get '/signup' do
  erb :signup
end

get '/users' do
  if session[:name] != nil
    user = User.first(username: session[:name])
    @totalWinsdb = user.totalWins
    @totalLossdb = user.totalLoss
    @totalProfitdb = user.totalProfit
    session[:totalWin] = user.totalWins
    session[:totalLoss] = user.totalLoss
    session[:totalProfit] = user.totalProfit
    session[:win] = 0
    session[:loss] = 0
    session[:profit] = 0
    @winSess = session[:win]
    @lossSess = session[:loss]
    @profitSess = session[:profit]
    erb :bet
  else
    redirect '/'
  end
end

get '/bet' do
  if session[:name] != nil
    user = User.first(username: session[:name])
    @totalWinsdb = session[:totalWin]
    @totalLossdb = session[:totalLoss]
    @totalProfitdb = session[:totalProfit]
    @winSess = session[:win]
    @lossSess = session[:loss]
    @profitSess = session[:profit]
    erb :bet
  else
   redirect '/'
  end
end
