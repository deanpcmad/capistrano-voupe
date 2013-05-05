Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :web do
      task :disable, :roles => :web, :except => { :no_release => true } do
        require 'erb'
        on_rollback { run "rm #{shared_path}/system/maintenance.html" }

        template_location = File.expand_path("../templates/maintenance.html.erb", __FILE__)

        template = File.read(template_location)

        result = ERB.new(template).result(binding)

        put result, "#{shared_path}/system/maintenance.html", :mode => 0644
      end
    end
  end
end