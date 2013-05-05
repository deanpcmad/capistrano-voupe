Capistrano::Configuration.instance.load do

	# require "base"
	require "capistrano-voupe/check"
	require "capistrano-voupe/nginx"
	require "capistrano-voupe/unicorn"
	require "capistrano-voupe/assets"
	require "capistrano-voupe/maintenance"
	require "capistrano-voupe/mysql"
	require "capistrano-voupe/log_deployment"

	default_run_options[:pty] = true
	ssh_options[:forward_agent] = true

	set :scm, "git"

	set :user, "deploy"
	set :deploy_via, :remote_cache
	set :use_sudo, false
	set :keep_releases, 5
	
	## deploying to production is the default
	set :rails_env, fetch(:rails_env, nil) || "production"
	set :environment, fetch(:environment, nil) || "production"
	set :deploy_to, "/opt/apps/#{application}"

	## return the deployment path
	## if :deploy_to isn't set in deploy.rb use the default
	def deploy_to
		fetch(:deploy_to, nil) || "/opt/apps/#{fetch(:application)}"
	end

	## Set the `current_revision` 
	# set(:current_revision)  { capture("cd #{deploy_to} && git log --pretty=%H -n 1", :except => { :no_release => true }).chomp }



	# namespace :deploy do
	#   desc "Deploy the MFer"
	#   task :default do
	#     update
	#     restart
	#     cleanup
	#   end
	# end






	## ==================================================================
	## init
	## ==================================================================
	desc 'Restart the whole remote application'
	task :restart, :roles => :web do
		# warn "[DEPRECATED] `restart` isn't used anymore. `deploy:restart` should be used instead."
		unicorn.restart
	end

	desc 'Stop the whole remote application'
	task :stop, :roles => :web do
		# warn "[DEPRECATED] `stop` isn't used anymore. `deploy:stop` should be used instead."
		unicorn.stop
	end

	desc 'Start the whole remote application'
	task :start, :roles => :web do
		# warn "[DEPRECATED] `start` isn't used anymore. `deploy:start` should be used instead."
		unicorn.start
	end
	
end