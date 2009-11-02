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

task "Create new post"
task :post do
  require 'erb'
  require 'ostruct'
  if ARGV.size < 2
    puts 'rake post "Some title"'
    exit
  end
  title = ARGV[1]
  tpl = File.read('templates/post.erb')
  now = Time.now
  slug = title.downcase.gsub(/[\s\.]+/, '-').gsub(/[^a-z0-9\-]/, '').gsub(/\-{2,}/, '-')
  filename = "content/blog/#{Time.now.strftime('%Y-%m-%d-')}#{slug}.textile"
  File.open(filename, "w") { |f| f.write ERB.new(tpl).result(binding) }
  system "$EDITOR #{filename}"
end

task :deploy => [:compile_less, :"deploy:rsync"]
