require 'nanoc3/tasks'

desc "Link static assets to output dir"
task :link_assets do
  %w(css javascripts images favicon.ico robots.txt).each do |file|
    `ln -s ../assets/#{file} output/#{file}`
  end
end

desc "Compile .less"
task :compile_less do
    `lessc assets/css/master.less`
end
