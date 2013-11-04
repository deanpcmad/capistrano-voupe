namespace :symlink do
	desc <<-DESC
	Symlinks shared/config/passport.key to current/config/passport.key
	DESC
	task :passport, :roles => :app, :except => {:no_release => true} do
		run "ln -nfs #{shared_path}/config/passport.key #{release_path}/config/passport.key"
	end
end

after "mysql:symlink", "symlink:passport"