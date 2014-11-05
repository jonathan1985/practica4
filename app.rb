#/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'uri'
require 'pp'
#require 'socket'
require 'data_mapper'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
# require 'pry'
require 'bundler/setup'
# require 'erubis'

use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier'], config['secret']
end

enable :sessions
set :session_secret, '*&(^#234a)'


DataMapper.setup( :default, ENV['DATABASE_URL'] || 
                            "sqlite3://#{Dir.pwd}/my_shortened_urls.db" )
DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true 

require_relative 'model'

DataMapper.finalize

#DataMapper.auto_migrate!
DataMapper.auto_upgrade!

Base = 36

#----------------------------------

get '/' do
  @mail = nil
  puts "inside get '/': #{params}"
  if session[:email] then
	begin
	  puts "inside get '/': #{params}"
	  @list = ShortenedUrl.all(:order => [ :id.asc ], :limit => 20, :usuario => session[:email])
	  # in SQL => SELECT * FROM "ShortenedUrl" ORDER BY "id" ASC
	end
  else
	@list = ShortenedUrl.all(:order => [ :id.asc ], :limit => 20, :usuario => session[:email])
  # in SQL => SELECT * FROM "ShortenedUrl" ORDER BY "id" ASC
  end
  haml :index
end


#----------------------------------

#----------------------------------

get '/auth/:name/callback' do
#   session[:auth] = @auth = request.env['omiauth.auth']
#   session[:email] = @auth['info'].email
#   if session[:auth] then
  @auth = request.env['omniauth.auth']
  session[:name] = @auth['info'].name
  session[:email] = @auth['info'].email
  if session[:email] then
	begin
	  @mail = session[:email]
	  puts "inside get '/': #{params}"
	  @list = ShortenedUrl.all(:order => [ :id.asc ], :limit => 20, :usuario => session[:email])
	  # in SQL => SELECT * FROM "ShortenedUrl" ORDER BY "id" ASC
	end
  else
	redirect '/nologin'
  end
  haml :index
end



#----------------------------------

get '/nologin' do  
  session.clear
  redirect '/'
end
  

#---------------------------------

post '/' do
  puts "inside post '/': #{params}"
  uri = URI::parse(params[:url])
  if uri.is_a? URI::HTTP or uri.is_a? URI::HTTPS then
    begin
	  if params[:opcional] == " "
		@short_url = ShortenedUrl.first_or_create(:url => params[:url], :usuario => session[:email]) 
	  else
		@short_url = ShortenedUrl.first_or_create(:url => params[:url], :opcional => params[:opcional], :usuario => session[:email])
	  end
    rescue Exception => e
      puts "EXCEPTION!!!!!!!!!!!!!!!!!!!"
      pp @short_url
      puts e.message
    end
  else
    logger.info "Error! <#{params[:url]}> is not a valid URL"
  end

  redirect '/'
#   if @auth then
# 	redirect '/auth/:name/callback'
#   else
#     redirect '/auth/nologin'
#   end
end


#----------------------------------

get '/:shortened' do
  puts "inside get '/:shortened': #{params}"
  short_url = ShortenedUrl.first(:id => params[:shortened].to_i(Base))
  to_url = ShortenedUrl.first(:opcional => params[:shortened])
  # HTTP status codes that start with 3 (such as 301, 302) tell the
  # browser to go look for that resource in another location. This is
  # used in the case where a web page has moved to another location or
  # is no longer at the original location. The two most commonly used
  # redirection status codes are 301 Move Permanently and 302 Found.
  if to_url
	redirect short_url.url, 301
  else
	redirect short_url.url, 301
  end
end

error do haml :index end
