set :application, "homepage"
set :scm, :git
set :repository, "git@github.com:sickill/homepage.git"
set :branch, "master"
set :user, "kill"
set :use_sudo, false
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
server "ku1ik.com", :app, :web, :db, :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end
