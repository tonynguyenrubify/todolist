require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require "capistrano-rbenv"
require 'sidekiq/capistrano'

default_run_options[:pty] = true
set :keep_releases, 5
set :application, "Application Name" # e.g: "Application Name" 
set :repository, "git@github.com:tonynguyenrubify/todolist.git" # e.g: "git@github.com:orangejuice175/deploy_app.git"
set :scm, :git
set :rake,  "bundle exec rake"
set :stages, ["staging", "production"]
set :default_stage, "staging"
set :use_sudo,  false
set :deploy_via, :remote_cache
set :rake,  "bundle exec rake"

load 'deploy/assets'

after 'deploy:finalize_update', 'deploy:symlink_share', 'deploy:generate_binstubs'
after "deploy:update", "deploy:cleanup"
after  "deploy:restart", "delayed_job:restart"

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

namespace :deploy do
  desc "Zero-downtime restart of Unicorn"  
  task :force_restart, roles: :app do
    # run "service unicorn upgrade"
    if remote_file_exists?("#{shared_path}/pids/todolist_app.pid")
      run "kill -s QUIT `cat #{shared_path}/pids/todolist_app.pid`"
    end
    sleep(3)
    run "cd #{current_path} ; bundle exec unicorn -c config/unicorn.rb -D -E #{rails_env}"  
  end

  task :restart, roles: :app do
    if remote_file_exists?("#{shared_path}/pids/todolist_app.pid")
      run "kill -s USR2 `cat #{shared_path}/pids/todolist_app.pid`"
    end
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true }, roles: :app  do
    run "cd #{current_path} ; bundle exec unicorn -c config/unicorn.rb -D -E #{rails_env}"
    # run "cd #{current_path}; touch tmp/restart.txt"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true }, roles: :app  do
    run "kill -s QUIT `cat #{shared_path}/pids/todolist_app.pid`"
  end

  desc 'migrate database'
  task :generate_binstubs, roles: :app do
    begin
      run "cd #{release_path} && bundle install --binstubs"
      run "cd #{release_path} && RAILS_ENV=#{rails_env} bin/rake db:migrate"      
    rescue => e
    end
  end

  desc 'Symlink share'
  task :symlink_share, roles: :app do
    ## Link System folder 
    run "mkdir -p #{shared_path}/system"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"

    run "mkdir -p #{shared_path}/build"
    run "ln -nfs #{shared_path}/build #{release_path}/public/build"

    ## Link Database file
    run "rm -f #{release_path}/config/database.yml"    
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start do
    p "Starting Delayed Job"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/delayed_job start"
  end

  desc "Stop delayed_job process"
  task :stop do
    p "Stopping Delayed Job"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/delayed_job stop"
  end

  desc "Restart delayed_job process"
  task :restart do
    p "Restarting Delayed Job"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/delayed_job restart"
  end
end