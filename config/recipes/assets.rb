namespace :assets do
	desc "Compile assets for production"
	task :compile, :roles => :web do
		run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake cdn:upload:all RAKE_USER='pete' RAKE_API='232123' RAKE_FILES='booo' --trace"
	end
end

after 'deploy:update_code', 'assets:compile'