Capistrano::Configuration.instance.load do

	namespace :symlink do
		desc <<-DESC
		Symlinks shared/config/settings/production.yml to current/config/settings/production.yml
		DESC
		task :rails_config, :roles => :app, :except => {:no_release => true} do
			run "ln -nfs #{shared_path}/config/settings/production.yml #{release_path}/config/settings/production.yml"
		end
	end

	after "mysql:symlink", "symlink:rails_config"

end