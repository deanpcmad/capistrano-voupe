require "delayed/recipes"

Capistrano::Configuration.instance.load do

	after "deploy:stop",    "delayed_job:stop"
	after "deploy:start",   "delayed_job:start"
	after "deploy:restart", "delayed_job:restart"

end