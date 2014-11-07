app_root = "/home/giangnguyen/www/todolist_app/current"
Dir.chdir(Unicorn::HttpServer::START_CTX[:cwd] = app_root)
working_directory app_root

Unicorn::HttpServer::START_CTX[0] = "#{app_root}/bin/unicorn"
pid_file = File.join(File.dirname(__FILE__), "../../../shared/pids/todolist_app.pid")
stderr_path File.join(File.dirname(__FILE__), "../../../shared/log/todolist_app.log")
stdout_path File.join(File.dirname(__FILE__), "../../../shared/log/todolist_app.log")
old_pid = pid_file + '.oldbin'

pid pid_file
listen "/tmp/todolist_app.sock"
worker_processes (ENV['RACK_ENV'] || ENV['RAILS_ENV']) == "production" ? 5 : 1
preload_app true
timeout 3000


before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{app_root}/Gemfile"
end

before_fork do |server, worker|

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH      
    end
  end

  # Throttle the master from forking too quickly by sleeping.
  sleep 1
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis. TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)

  begin
    uid, gid = Process.euid, Process.egid
    if (ENV['RACK_ENV'] || ENV['RAILS_ENV']) == "production"
      user, group = 'giangnguyen', 'giangnguyen'
    else
      user, group = 'giangnguyen', 'giangnguyen'
    end
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    # if Rails.env == 'development'
    #   STDERR.puts "couldn't change user, oh well"
    # else
    #   raise e
    # end
  end
end