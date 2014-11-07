server "192.168.1.160", :app, :web, :db, :primary => true
set :rails_env, "staging"
set :user, 'giangnguyen'
set :branch, :master
set :deploy_to, "/home/giangnguyen/www/todolist_app"

default_run_options[:pty] = true
set :default_environment, {
  'PATH' => "/home/giangnguyen/.rbenv/shims:/home/giangnguyen/.rbenv/bin:$PATH"
}