require 'sinatra'
require './database_info'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database_info.db")


DataMapper.finalize.auto_upgrade!

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/database_info.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

# Navigates the user to the login page when there is no absolute path mentioned in url.
get '/' do
  erb :login
end

# When the request comes from the signup page we will check whether the username exists or not. If it exists then it will return an error message.
post '/signup' do
  if(!User.first(username: params[:username]))
    User.create(username: params[:username], password: params[:password],totalWins:"0",totalLoss:"0",totalProfit:"0")
    session[:message] = "Username #{params[:username]} is created"
    redirect '/'
  else
    session[:message] = "Username #{params[:username]} is already created"
    redirect '/signup'
  end
end

#Finds the user with given username and returns an error message if the username or password is incorrect.
post '/login' do
  user = User.first(username: params[:username])
  if user != nil  && user.password != nil &&
      params[:password] == user.password
      session[:name] = params[:username]
      redirect to '/users'
  else
      session[:message] = "Username or Password is incorrect"
      redirect '/'
  end
end

#When the user plays gambling and bets on a given dice number then the request is catched here
post '/bet' do
  money = params[:money].to_i
  number = params[:number].to_i

  # Rolls the dice and get the number and if the number is same as predicted value of user then the user wins the bet.
  roll = rand(6) + 1
  if number == roll
    save_session(:win, 5*money)
    save_session(:profit, 4*money)
    save_session(:totalWin, 5*money)
    save_session(:totalProfit, 4*money)
    session[:message] = "The dice landed on #{roll}, you choose #{number} and you won #{5*money} dollars"
  else
    save_session(:loss, money)
    save_session(:profit, -1*money)
    save_session(:totalLoss, money)
    save_session(:totalProfit, -1*money)

    session[:message] = "The dice landed on #{roll}, you choose #{number} and you lost #{money} dollars"
  end
  redirect '/bet'
end

# Removes the user from the session when user clicks on logout button.
post '/logout' do
  user = User.first(username: session[:name])
  user.update(totalWins: session[:totalWin])
  user.update(totalLoss: session[:totalLoss])
  user.update(totalProfit: session[:totalProfit])
  session[:login] = nil
  session[:name] = nil
  redirect '/'
end

def save_session(parameter, money)
  count = (session[parameter] || 0).to_i
  count += money
  session[parameter] = count
end

not_found do
  "Page not found"
end
