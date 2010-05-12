require 'nanoc3/tasks'

desc "Compile site"
task :compile do
  system "bundle exec nanoc compile"
end

task :rmrf do
  system "rm -rf public"
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
  if File.exist?(filename)
    raise RuntimeError.new("File #{filename} already exists!")
  else
    File.open(filename, "w") { |f| f.write ERB.new(tpl).result(binding) }
    puts "running: #{ENV['EDITOR']} #{filename}"
    system "$EDITOR #{filename}"
  end
end

desc "Start local adsf server"
task :server do
  system "bundle exec adsf -H thin -p 4000 -r public"
end

desc "Build site from scratch"
task :build => [:rmrf, :compile]

desc "Deploy"
task :deploy => ["deploy:rsync"]
