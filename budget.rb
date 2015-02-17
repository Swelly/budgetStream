## Using Sinatra DSL and Ruby 2.2.0 ##

## Gems ##
require "sinatra"
require "data_mapper"
require "json"
require "sinatra/reloader" if development?


## Setting up a default SQLite3 DB for dev ##

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/budget.db")

class Budget
  include DataMapper::Resource
  property :id, Serial
  property :title, Text, :required => true
  property :length, Integer, :required => true, :default => 0
  property :initial, Integer, :required => true, :default => 0
  property :created_at, DateTime
  property :updated_at, DateTime
end

class Fund
  include DataMapper::Resource
  property :id, Serial
  property :b_id, Integer, :required => true
  property :amount, Integer, :required => true
  property :description, Text, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!


## Beginning API ##

# HomePage
get '/' do
  'Homepage SON!'
end

## Budget

#  See All and Create Budgets
# First Rest call
get '/budget' do
  bud = Budget.all order: :id.desc
  bud.to_json
end

# See an individual budget
get '/budget/:id' do
  b = Budget.get params[:id] # Todo -- Check for existence
  b.to_json
end

# Make a new Budget in DB with POST request to change data on the server
post '/budget' do
  b = Budget.new
  b.title = params[:title]
  b.length = params[:length]
  b.initial = params[:initial]
  b.created_at = Time.now
  b.updated_at = Time.now
  b.save
  b.to_json
end

# Edit a budget (request and overwrite) with PUT to overwrite data
put '/budget/:id' do
  b = Budget.get params[:id] # Todo -- Add a check if it exists
  b.title = params[:title]
  b.length = params[:length]
  b.initial = params[:initial]
  b.updated_at = Time.now
  b.save
  # return new object to the user to verify edit
  b.to_json
end

# Deleting a budget using DELETE (Destroy)
delete '/budget/:id' do
  b = Budget.get params[:id] # TODO -- Add a check if it exists
  b.destroy
  # Display status after destruction
  status 200, "Budget #{:id} deleted"
end

## Funds

# View funds for a budget (find all funds associated with budget id)
get '/budget/:id/fund' do
  funds = Fund.all :b_id => params[:id]
  funds.to_json
end

# Add a fund to budget with specific ID
post '/budget/:id/fund' do
  f = Fund.new
  f.b_id = params[:id]
  f.amount = params[:amount]
  # Description NOT required
  if params[:description]
    f.description = params[:description]
  end
  f.created_at = Time.now
  f.updated_at = Time.now
  f.save
  f.to_json
end

# Deleting a Fund
delete '/budget/:id/fund/:f_id' do
  f = Fund.get params[:id] ##
  f.destroy
  # Display status after destruction
  status 200, "Fund #{f_id} deleted for budget #{params[:id]}"
end

if Budget.count == 0
  Budget.create(:title => "Test Budget", :length => 7, :initial => 10000, :created_at => Time.now, :updated_at => Time.now)
  Budget.create(:title => "Test Budget Two", :length => 14, :initial => 5000, :created_at => Time.now, :updated_at => Time.now)
end
