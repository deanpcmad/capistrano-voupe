namespace :resque do
	desc <<-DESC
	Restart the Resque workers for an application after a deploy or deploy:migrations
	DESC
	task :restart_workers, :roles => :app, :except => {:no_release => true} do
		if exists?(:resque_queues)
			fetch(:resque_queues).each do |queue_name, worker_count|
				1.upto(worker_count) do |worker_index|
					run "sv restart resque-#{fetch(:application)}-#{queue_name}-worker-#{worker_index}"
				end
			end
		else
			logger.info("You must define the :resque_queues variable for the resque:restart_workers task to work")
		end
	end
end

after "deploy", "resque:restart_workers"
after "deploy:migrations", "resque:restart_workers"