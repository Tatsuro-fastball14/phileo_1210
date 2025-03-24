# Puma thread configuration
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Port to listen on
port ENV.fetch("PORT") { 3000 }

# Environment configuration
environment ENV.fetch("RAILS_ENV") { "production" }

# PID file location
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Worker configuration for clustered mode
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Preload application for better performance
preload_app!

# Allow Puma to be restarted by `rails restart`
plugin :tmp_restart

# Worker boot configuration
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
