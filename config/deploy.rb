require 'bundler/capistrano'

#############################################
##                                         ##
##              Configuration              ##
##                                         ##
#############################################

GITHUB_REPOSITORY_NAME = 'r13-team-284'
LINODE_SERVER_HOSTNAME = '50.116.4.120'

#############################################
#############################################

# General Options

set :bundle_flags,               "--deployment"

set :application,                "railsrumble"
set :deploy_to,                  "/var/www/apps/railsrumble"
set :normalize_asset_timestamps, false
set :rails_env,                  "production"

set :user,                       "root"
set :runner,                     "www-data"
set :admin_runner,               "www-data"

ssh_options[:keys] = ["~/.ssh/id_rsa"]

# SCM Options
set :scm,        :git
set :repository, "git@github.com:railsrumble/#{GITHUB_REPOSITORY_NAME}.git"
set :branch,     "master"

# Roles
role :app, LINODE_SERVER_HOSTNAME
role :db,  LINODE_SERVER_HOSTNAME, :primary => true

# Add Configuration Files & Compile Assets
after 'deploy:update_code' do
  # Setup Configuration
  run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"

  # Compile Assets
  run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
end

after "deploy:update_code", "deploy:migrate"


# Restart Passenger
deploy.task :restart, :roles => :app do
  # Fix Permissions
  sudo "chown -R www-data:www-data #{current_path}"
  sudo "chown -R www-data:www-data #{latest_release}"
  sudo "chown -R www-data:www-data #{shared_path}/bundle"
  sudo "chown -R www-data:www-data #{shared_path}/log"

  # Restart Application
  run "touch #{current_path}/tmp/restart.txt"
end

namespace :rails do
  desc "Open the rails console on one of the remote servers"
  task :console, :roles => :app do
    hostname = find_servers_for_task(current_task).first
    exec "ssh -l #{user} #{hostname} -t 'source ~/.profile && #{current_path}/bin/rails c #{rails_env}'"
  end
end
