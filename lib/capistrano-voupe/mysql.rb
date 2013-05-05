Capistrano::Configuration.instance(true).load do
  set_default(:mysql_host, "localhost")
  set_default(:mysql_user) { application }
  set_default(:mysql_password) { Capistrano::CLI.password_prompt "MySQL Password for #{mysql_user}: " }
  set_default(:mysql_database) { "#{application}_prod" }
  set_default(:mysql_root_password) { Capistrano::CLI.password_prompt "MySQL Root Password: " }
  set_default(:mysql_setup) { false }

  after "deploy:setup", "mysql:create_database" if fetch(:mysql_setup) == true

  namespace :mysql do
    desc "Create a database for this application."
    task :create_database, roles: :db, only: {primary: true} do
      # create user
      run %Q{#{sudo} mysql -uroot -p#{mysql_root_password} -e "CREATE USER '#{mysql_user}'@'%' IDENTIFIED BY '#{mysql_password}'"; }
      # create database
      run %Q{#{sudo} mysql -uroot -p#{mysql_root_password} -e "CREATE DATABASE #{mysql_database}"; }
      # set permissions for the new database for the new user
      run %Q{#{sudo} mysql -uroot -p#{mysql_root_password} -e "GRANT ALL PRIVILEGES ON #{mysql_database}.* TO #{mysql_user}@'%' IDENTIFIED BY '#{mysql_password}'"; }
      # flush privileges
      run %Q{#{sudo} mysql -uroot -p#{mysql_root_password} -e "FLUSH PRIVILEGES"; }
    end

    desc "Generate the database.yml configuration file."
    task :setup, roles: :app do
      run "mkdir -p #{shared_path}/config"
      template "mysql.yml.erb", "#{shared_path}/config/database.yml"
    end
    after "deploy:setup", "mysql:setup"

    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
    after "deploy:finalize_update", "mysql:symlink"
  end
end