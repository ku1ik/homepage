set :application, "theblog"
set :domain,      "theblog.sickill.net"
set :deploy_to,   "/home/kill/blog"
set :repository,  "kill@sickill.net:repos/blog"

set :merb_env,    "development"
# TODO Create the production versions of these files in the
#      shared/config directory on the server.
set :config_files, ['database.yml'] #, 'merb.yml']

task :deploy => ["merb:deploy:update", "merb:deploy:copy_config_files", "merb:deploy:restart_app"]

namespace :merb do

  namespace :deploy do

    now = Time.now.utc.strftime("%Y%m%d%H%M.%S")
    merb_port = 5000

    remote_task :update, :roles => :app do
      symlink = false
      begin
        # TODO: head/version should be parameterized
        run [ "cd #{scm_path}",
          "#{source.checkout "head", '.'}",
          "#{source.export ".", release_path}",
          "chmod -R g+w #{latest_release}",
          "rm -rf #{latest_release}/log #{latest_release}/public/system",
          "ln -s #{shared_path}/log #{latest_release}/log",
          "ln -s #{shared_path}/system #{latest_release}/public/system"
        ].join(" && ")

        asset_paths = %w(images stylesheets javascripts).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
        run "find #{asset_paths} -exec touch -t #{now} {} ';'; true"

        symlink = true
        run "rm -f #{current_path} && ln -s #{latest_release} #{current_path}"

        run "echo #{now} $USER #{'head'} #{File.basename release_path} >> #{deploy_to}/revisions.log" # FIX shouldn't be head
      rescue => e
        run "rm -f #{current_path} && ln -s #{previous_release} #{current_path}" if
        symlink
        run "rm -rf #{release_path}"
        raise e
      end
    end

    desc "Copy config files from shared/config to release dir"
    remote_task :copy_config_files, :roles => :app do
      config_files.each do |filename|
        run "cp #{shared_path}/config/#{filename} #{release_path}/config/#{filename}"
      end
    end

    # TODO These need to only restart the app being deployed.
    desc "Restart merb"
    remote_task :restart_app, :roles => :app do
      #run "/etc/init.d/merb restart"
    end

    desc "start merb"
    remote_task :start_app, :roles => :app do
      #run "/etc/init.d/merb start"
      "cd #{current_path} && merb -p #{merb_port} -e #{merb_env}"
    end

    desc "stop merb"
    remote_task :stop_app, :roles => :app do
#      run "/etc/init.d/merb stop"
      "cd #{current_path} && merb -p #{merb_port} -e #{merb_env} -K all"
    end

    desc "Migrate for Merb"
    remote_task :migrate, :roles => :db do
      run "cd #{current_release}; rake db:migrate MERB_ENV=#{merb_env}"
    end

    desc "Delete repository cache, to start over from a fresh copy."
    remote_task :delete_repository_cache do
      run "rm -rf #{File.join([deploy_to, 'scm'])}"
    end

  end

end

