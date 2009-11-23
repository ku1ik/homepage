require 'nanoc3/tasks'

desc "Link static assets to output dir"
task :link_assets do
  %w(css javascripts images favicon.ico robots.txt).each do |file|
    `ln -s ../assets/#{file} output/#{file}`
  end
end

desc "Compile .less"
task :compile_less do
  puts "Compiling .less"
  `lessc assets/css/master.less`
end

desc "Create new post"
task :post do
  require 'erb'
  require 'ostruct'
  title = ENV['title']
  markup = ENV['markup'] || 'textile'
  if title.nil?
    puts 'rake post title="Some title"'
    exit
  end
  tpl = File.read('templates/post.erb')
  now = Time.now
  slug = title.downcase.gsub(/[\s\.]+/, '-').gsub(/[^a-z0-9\-]/, '').gsub(/\-{2,}/, '-')
  filename = "content/blog/#{Time.now.strftime('%Y-%m-%d-')}#{slug}.#{markup}"
  File.open(filename, "w") { |f| f.write ERB.new(tpl).result(binding) }
  puts "running: #{ENV['EDITOR']} #{filename}"
  system "$EDITOR #{filename}"
end

desc "Start local adsf server"
task :server do
  system "cd output; adsf -p 4000 &"
  system "sleep 1; firefox http://localhost:4000/"
end

task :deploy => [:compile_less, :"deploy:rsync"]
