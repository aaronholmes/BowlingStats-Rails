

namespace :assets do
	desc "Compile assets for production"
	task :compile, :roles => :web do
		symlink
		run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake cdn:upload:all --trace"
	end
	after 'deploy:update_code', 'assets:compile'

	desc "Setup constants for CDN"
	task :setupcdn, :roles => :web do
		set_default(:rack_user) { Capistrano::CLI.password_prompt "Rackspace User: " }
		set_default(:rack_api) { Capistrano::CLI.password_prompt "Rackspace API: " }
		set_default(:rack_files) { Capistrano::CLI.password_prompt "Rackspace CloudFiles Bucket: " }

		run "mkdir -p #{shared_path}/config"
    	template "constants.erb", "#{shared_path}/config/constants.rb"
    	symlink
	end

	desc "Symlink the constants file into latest release"
	task :symlink, roles: :app do
	run "ln -nfs #{shared_path}/config/constants.rb #{release_path}/config/constants.rb"
	end
	after "deploy:finalize_update", "assets:symlink"
end

