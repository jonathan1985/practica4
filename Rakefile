desc "run the http server"
task :default do
  sh "ruby app.rb"
end

desc "run the server via rackup"
task :rackup do
  sh "rackup"
end

desc "Test"
task :test do
  sh "ruby test/test.rb"
end

# substitute XXX for the name of your app
desc "create heroku app"
task :create, :appname do |t,args|
  name = args[:appname] || 'XXX';
  sh "heroku create #{name}"
end

desc "deploy  heroku app"
task :deploy  do
  sh "git push heroku master"
end

desc "ps"
task :deploy  do
  sh "heroku ps"
end

desc "logs"
task :logs  do
  sh "heroku logs"
end

desc "destroy deployment in heroku"
task :logs, :appname  do
  name = args[:appname] || 'XXX';
  sh "heroku apps:destroy #{name}"
end

desc "Save config.yml out of the CVS"
task :keep_secrets do
  sh "cp config/config_template.yml config/config.yml "
end

desc "Use the filled client_secrets"
task :use_keys do
  sh "cp config/config_filled.yml config/config.yml"
end

