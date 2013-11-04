require "httparty"

after "deploy:create_symlink", "voupe:log_deployment"

namespace :voupe do
  desc "Logs the deployment to the Dashboard"
  task :log_deployment do

    if previous_revision == current_revision
      logger.info "The old revision & new revision are the same - you didn't deploy anything new. Skipping logging."
      next
    end

    # only if dashboard_site_uuid exists
    unless fetch(:dashboard_site_uuid, nil) == nil

      set :branch, (respond_to?(:branch) ? branch : 'master')
      
      if respond_to?(:environment)
        set :environment, environment
      elsif respond_to?(:rails_env)
        set :environment, rails_env
      end

      start_ref = previous_revision or "0000000000000000000000000000000000000000"
      end_ref = current_revision
      servers = roles.values.collect{|r| r.servers}.flatten.collect{|s| s.host}.uniq.join(',') rescue ''
      
      options = [previous_revision, current_revision, environment, branch].join("/")

      deploy_track_url = "https://dash.voupe.com/track_deploy/#{fetch(:dashboard_site_uuid)}/#{options}"

      response = HTTParty.post(deploy_track_url)

    else
      logger.info "The :dashboard_site_uuid variable isn't present. Add it to config/deploy.rb to log deploments"
    end

  end
end