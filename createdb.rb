# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :restaurants do
  primary_key :id
  String :title
  String :description, text: true
  String :phone
  String :location
end
DB.create_table! :posts do
  primary_key :id
  foreign_key :restaurant_id
  foreign_key :user_id
  Boolean :like
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
restaurants_table = DB.from(:restaurants)

restaurants_table.insert(title: "Ryo Sushi", 
                    description: "Ryo Sushi is a great sushi spot in the middle of the loop!  The fish is super fresh and portions generous.  I love the green dragon, red dragon, rainbow and tuna avocado rolls!",
                    phone: "(312) 409-8888",
                    location: "62 E Madison St, Chicago, IL 60602")

restaurants_table.insert(title: "Happy Camper", 
                    description: "Happy Camper is a great local mini-chain with two locations, one in Old Town and another in Wrigleyville, and a sister restaurant called Homeslice.  They specialize in thin pizzas with fluffy crusts and less traditional toppings.  During the quarantine they put together some great takeout specials like the party for one: a small pepperoni pizza, cookie dough tub, a six pack of beers and a Smirnoff Ice.",
                    phone: "(312) 344-1634",
                    location: "1209 N Wells St, Chicago, IL 60610")
