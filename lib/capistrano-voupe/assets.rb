Capistrano::Configuration.instance.load do

	set :asset_directory, "public/assets"
	set :asset_dependencies, %w(app/assets Gemfile.lock config/routes.rb)

	namespace :deploy do
		namespace :assets do
			# task :precompile_with_skip, :roles => :web, :except => {:no_release => true} do
			task :precompile, :roles => :web, :except => {:no_release => true} do
				from = source.next_revision(current_revision)
				if capture("cd #{latest_release} && #{source.local.log(previous_revision, current_revision)} #{asset_dependencies.join('')} | wc -l").to_i > 0
					run "cd #{fetch(:current_path)} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
				else
					logger.info "Skipping asset pre-compilation because there were no asset changes. Copying assets from #{previous_release}"
					run "cp -R #{previous_release}/#{asset_directory} #{latest_release}/#{asset_directory}"
				end
			end
		end
	end

end