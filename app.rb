require_relative "lib/models"
require_relative "lib/helpers"
require_relative "lib/atom"
require_relative "lib/time"

set :root, File.dirname(__FILE__)
set :static, true
set :tags_add_newlines_after_tags, false

helpers BasicHelpers
helpers AtomHelper
helpers Sinatra::Tags

get "/" do
  @header = "latest writings"
  @posts = Post.recent(15)
  erb :post_list
end

get "/blog/:year/:month/:day/:title/?" do
  @post = Post.find_by_slug(params[:title].split(".").first)
  if @post
    @show_comments = true
    RubyPants.new(erb(:post).force_encoding("UTF-8")).to_html
  else
    pass
  end
end

get "/blog/tag/:tag/?" do
  @header = "writings on <em>#{params[:tag]}</em>"
  @posts = Post.find_by_tag(params[:tag])
  erb :post_list
end

get %r(/blog/(\d{4})/?) do
  year = params[:captures].first
  @header = "Year #{year}"
  @posts = Post.find_by_year(year.to_i)
  erb :post_list
end

get %r(/(me|about-me|contact)/?) do
  content = RDiscount.new(erb(File.read("content/me.markdown"), :layout => false)).to_html
  erb content
end

get "/atom.xml" do
  @site = OpenStruct.new(:config => { :base_url => "http://ku1ik.com" })
  opts = {
    :title => "Marcin Kulik's tech stuff",
    :author_name => "Marcin Kulik",
    :author_uri => "http://ku1ik.com/",
    :feed_url => "http://feeds2.feedburner.com/SickillNet",
    :articles => Post.recent(10),
    :limit => 10
  }
  content_type "application/atom+xml", :charset => "utf-8"
  atom_feed(opts)
end
