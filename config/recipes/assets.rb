namespace :assets do
	desc "Compile assets for production"
	task :compile, :roles => :web do
		run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile --trace"
		run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake cdn:upload:all --trace"
	end
end

after 'deploy:update_code', 'assets:compile'