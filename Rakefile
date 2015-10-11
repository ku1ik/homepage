# Adopted from Scott Kyle's Rakefile
# http://github.com/appden/appden.github.com/blob/master/Rakefile

task :default => :server

desc 'Build site with Jekyll'
task :build do
  jekyll 'build'
end

desc 'Build and start server with --auto'
task :server do
  jekyll 'serve -w'
end

desc 'Build and deploy'
task :deploy do
  sh %(rm -rf _site && jekyll build && mv _site _site-new && git checkout deploy && git rm -r _site && mv _site-new _site && git add -f _site && git commit -m "Deploy at #{Time.now.to_i}" && git checkout master && git push heroku deploy:master)
end

def jekyll(opts = '')
  sh 'rm -rf _site'
  sh 'jekyll ' + opts
end
