Capistrano::Configuration.instance(:true).load do

	require "capistrano-voupe/base"
	require "capistrano-voupe/check"
	require "capistrano-voupe/nginx"
	require "capistrano-voupe/unicorn"
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

	# stops the public/images, etc not found errors
	set :normalize_asset_timestamps, false
	
	## deploying to production is the default
	set :rails_env, fetch(:rails_env, nil) || "production"
	set :environment, fetch(:environment, nil) || "production"
	set :deploy_to, "/opt/apps/#{application}"

	## return the deployment path
	## if :deploy_to isn't set in deploy.rb use the default
	def deploy_to
		fetch(:deploy_to, nil) || "/opt/apps/#{fetch(:application)}"
	end


	## ==================================================================
	## init
	## ==================================================================
	desc 'Restart the whole remote application'
	task :restart, :roles => :web do
		unicorn.restart
	end

	desc 'Stop the whole remote application'
	task :stop, :roles => :web do
		unicorn.stop
	end

	desc 'Start the whole remote application'
	task :start, :roles => :web do
		unicorn.start
	end
	
end