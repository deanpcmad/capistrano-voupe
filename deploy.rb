# =============================================================================
# GENERAL SETTINGS
# =============================================================================

## Set the name for the application
set :application, "voupe_docs"

## Path where the application should be stored
## Stored in '/opt/apps/#{app_name}' by default
# set :deploy_to, "/opt/apps/voupe"

## Repository settings
set :repo_url, "git@codebasehq.com:voupe/documentation/app.git"
set :branch, "master"

## Server/app details
# server "docs.voupe.com", :web, :app, :db, primary: true
set :domain_name, "docs.voupe.com"

# Voupe Details
# set :dashboard_site_uuid, "2138a621-f60e-451e-8e63-4e8fd7df191c"

# =============================================================================
# RECIPE INCLUDES
# =============================================================================


set :user, "deploy"
set :deploy_via, :remote_cache
set :use_sudo, false
# set :keep_releases, 5

## deploying to production is the default
set :deploy_to, "/opt/apps/#{fetch(:application)}"



# set :application, 'my_app_name'
# set :repo_url, 'git@example.com:me/my_repo.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/secret_token.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

# namespace :deploy do

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       # Your restart mechanism here, for example:
#       # execute :touch, release_path.join('tmp/restart.txt')
#     end
#   end

#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end

#   after :finishing, 'deploy:cleanup'

# end

desc 'Restart the whole remote application'
task :restart do
  on roles(:web) do |host|
    unicorn.restart
  end
end

desc 'Stop the whole remote application'
task :stop do
  on roles(:web) do |host|
    unicorn.stop
  end
end

desc 'Start the whole remote application'
task :start do
  on roles(:web) do |host|
    unicorn.start
  end
end


# def template(from, to)
#   erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
#   put ERB.new(erb).result(binding), to
# end

# def set_default(name, *args, &block)
#   set(name, *args, &block) unless exists?(name)
# end

require "capistrano/voupe/base"

# def template(from, to)
#   puts "Template #{from} to #{to}"
#   template = File.read(File.expand_path("../../templates/#{from}", __FILE__))
#   # system "touch #{to}"
#   File.open(to, "w+") do |f|
#     f.write(ERB.new(template).result(binding))
#     puts I18n.t(:written_file, scope: :capistrano, file: to)
#   end
# end

namespace :deploy do

  task :setup do
    on roles(:all) do
      dirs = [deploy_to, releases_path, shared_path]
      execute :mkdir, "-p", dirs.join(' ')
      execute :chmod, "g+w", dirs.join(' ') if fetch(:group_writable, true)
    end
  end

end

# execute :mkdir, "-p", dirs.join(' ')
# execute :chmod, "g+w", dirs.join(' ') if fetch(:group_writable, true)


# def template(from, to)
#   template = File.read(from)
#   file = config_dir.join(to)
#   File.open(file, 'w+') do |f|
#     f.write(ERB.new(template).result(binding))
#     puts I18n.t(:written_file, scope: :capistrano, file: file)
#   end
# end


set :unicorn_user, fetch(:unicorn_user) || fetch(:user)
set :unicorn_pid, fetch(:unicorn_pid) || "#{current_path}/tmp/pids/unicorn.pid"
set :unicorn_config, fetch(:unicorn_config) || "#{shared_path}/config/unicorn.rb"
set :unicorn_log, fetch(:unicorn_log) || "#{shared_path}/log/unicorn.log"
set :unicorn_workers, fetch(:unicorn_workers, 1)

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup do
    on roles(:app) do |host|
      execute :mkdir, "-p", "#{shared_path}/config"
      execute :touch, "", "#{shared_path}/config/unicorn.rb"
      template "unicorn.rb.erb", fetch(:unicorn_config)
      # template "unicorn_init.erb", "/tmp/unicorn_init"
      execute :chmod, "+x", "/tmp/unicorn_init"
      run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{fetch(:application)}"
      run "#{sudo} update-rc.d -f unicorn_#{fetch(:application)} defaults"
    end
  end
  after "deploy:setup", "unicorn:setup"

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command do
      on roles(:app) do |host|
        execute "service unicorn_#{fetch(:application)} #{command}"
      end
    end
    # after "deploy:#{command}", "unicorn:#{command}"
  end
end

namespace :nginx do
  desc "Setup nginx configuration for this application"
  task :setup do
    on roles(:web) do |host|
      template "nginx_unicorn.erb", "/tmp/nginx_conf"
      execute "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{fetch(:application)}"
      execute "#{sudo} rm -f /etc/nginx/sites-enabled/default"
      restart
    end
  end
  after "deploy:setup", "nginx:setup"
  
  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command do
      on roles(:web) do |host|
        execute "#{sudo} service nginx #{command}"
      end
    end
  end
end

set :mysql_host, fetch(:mysql_host) || "localhost"
set :mysql_user, fetch(:mysql_user) || fetch(:application)
set :mysql_database, fetch(:mysql_database) || "#{fetch(:application)}_prod"


after "deploy:setup", "mysql:create_database" if fetch(:mysql_setup) == true

namespace :mysql do
  desc "Generate the database.yml configuration file."
  task :setup do
    on roles(:app) do |host|
      execute :mkdir, "-p", "#{shared_path}/config"
      template "mysql.yml.erb", "#{shared_path}/config/database.yml"
    end
  end
  after "deploy:setup", "mysql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink do
    on roles(:app) do |host|
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
  # after "deploy:finalize_update", "mysql:symlink"
end



desc "Check that we can access everything"
task :check_write_permissions do
  on roles(:all) do |host|
    if test("[ -w #{fetch(:deploy_to)} ]")
      info "#{fetch(:deploy_to)} is writable on #{host}"
    else
      error "#{fetch(:deploy_to)} is not writable on #{host}"
    end
  end
end