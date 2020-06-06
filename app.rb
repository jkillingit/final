# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

restaurants_table = DB.from(:restaurants)
comments_table = DB.from(:comments)
users_table = DB.from(:users)

before do
    # SELECT * FROM users WHERE id = session[:user_id]
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
end

# Home page (all restaurants)
get "/" do
    # before stuff runs
    @restaurants = restaurants_table.all
    view "restaurants"
end

# Show a single restaurant
get "/restaurants/:id" do
    @users_table = users_table
    # SELECT * FROM restaurants WHERE id=:id
    @restaurant = restaurants_table.where(:id => params["id"]).to_a[0]
    # SELECT * FROM comments WHERE event_id=:id
    @comments = comments_table.where(:event_id => params["id"]).to_a
    view "restaurant"
end

# Form to create a new comment
get "/restaurants/:id/comments/new" do
    @restaurant = restaurants_table.where(:id => params["id"]).to_a[0]
    view "new_comment"
end

# Receiving end of new comment form
post "/restaurants/:id/comments/create" do
    comments_table.insert(:restaurant_id => params["id"],
                       :user_id => @current_user[:id],
                       :comment => params["comment"])
    @restaurant = restaurants_table.where(:id => params["id"]).to_a[0]
    view "create_comment"
end

# Form to create a new user
get "/users/new" do
    view "new_user"
end

# Receiving end of new user form
post "/users/create" do
    puts params.inspect
    users_table.insert(:name => params["name"],
                       :email => params["email"],
                       :password => BCrypt::Password.create(params["password"]))
    view "create_user"
end

# Form to login
get "/logins/new" do
    view "new_login"
end

# Receiving end of login form
post "/logins/create" do
    puts params
    email_entered = params["email"]
    password_entered = params["password"]
    # SELECT * FROM users WHERE email = email_entered
    user = users_table.where(:email => email_entered).to_a[0]
    if user
        puts user.inspect
        # test the password against the one in the users table
        if BCrypt::Password.new(user[:password]) == password_entered
            session[:user_id] = user[:id]
            view "create_login"
        else
            view "create_login_failed"
        end
    else 
        view "create_login_failed"
    end
end

# Logout
get "/logout" do
    session[:user_id] = nil
    view "logout"
end
