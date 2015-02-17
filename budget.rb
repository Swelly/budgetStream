require 'sinatra'
require 'data_mapper'
require "sinatra/reloader" if development?

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

# HomePage
get '/' do
  'home'
end

#  See All and Create Budgets
get '/budget' do
  @bud = Budget.all order: :id.desc
  @bud.to_json
end

# See individual budget
get '/budget/:id' do
  b = Budget.get params[:id] # Todo -- Check for existence
  b.to_json
end

# Make a new budget in DB
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

# Edit a budget (request and overwrite)
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

# Deleting a budget
delete '/budget/:id' do
  b = Budget.get params[:id] # TODO -- Add a check ?exists
  b.destroy
  # Display status after destruction
  status 200, "Budget #{id} deleted"
end

# View funds for a budget
get '/budget/:id/fund' do
  funds = Fund.all :b_id => params[:id]
  funds.to_json
end

# Add a fund to budget
post '/budget/:id/fund' do
  f = Fund.new
  f.b_id = params[:id]
  f.amount = params[:amount]
  f.description = params[:description]
  f.created_at = Time.now
  f.updated_at = Time.now
  f.save
  f.to_json
end

if Budget.count == 0
  Budget.create(:title => "Test Budget", :length => 7, :initial => 10000, :created_at => Time.now, :updated_at => Time.now)
  Budget.create(:title => "Test Budget Two", :length => 14, :initial => 5000, :created_at => Time.now, :updated_at => Time.now)
end
