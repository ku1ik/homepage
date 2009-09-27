module Nanoc3::Helpers::Blogging
  def articles
    @items.select { |item| item[:kind] == 'article' && !item[:draft] }
  end
end

include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::LinkTo
# include Nanoc3::Helpers::ImageTag

def image(thumb, normal, desc="")
  %(<a href="#{normal}" title="#{desc}">#{image_tag(thumb, desc)}</a>)
end

def image_tag(src, desc="")
  %(<img src="#{src}" alt="#{desc}" />)
end

def render_post_header(post)
  html = ""
  html << %(<h2 class="article-title">#{link_to post[:title], post.path}</h2><!-- by <strong>Sickill</strong>  -->)
  html << %(<div class="article-info">)
  html << %(Posted on #{post.created_at.strftime("%d %b %Y")}, )
  html << %(tagged with #{post.tags.map { |t| link_to(t, "/blog/tag/#{t}") }.join(", ")})
  html << %(</div>)
end

def render_post(post, opts={}, &blk)
  html = ""
  html << %(<div class="article">)
  html << render_post_header(post)
  html << %(  <br class="clear" />)
  html << %(<div class="article-content">)
  if block_given?
    html << capture(&blk)
  else
    html << post.content
  end
  html << %(</div>)
  if opts[:comments]
    html << %(<div id="disqus_thread"></div><script type="text/javascript" src="http://disqus.com/forums/sickill/embed.js"></script><noscript><a href="http://sickill.disqus.com/?url=ref">View the discussion thread.</a></noscript><a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>)
  else
    html << link_to("View Comments", post.path + "#disqus_thread")
  end
  html << %(</div>)
  
  # Append to erbout if we have a block
  if block_given?
    erbout = eval('_erbout', blk.binding)
    erbout << html
  end
  
  # return result
  html
end
  
# Returns the item with the given identifier.
def item(identifier)
  @items.find { |item| item.identifier == identifier }
end

def tags_and_items(items=nil)
  @items = items unless items.nil?
  articles.inject(Hash.new { |h,k| h[k] = [] }) do |acc, a|
    a.tags.each do |t| 
      acc[t] << a
    end
    acc
  end
end

def articles_tagged_with(tag)
  sorted_articles.select { |a| a.tags.include?(tag) }
end

def months_and_items
  articles.group_by do |p|
    time = Time.parse(p[:created_at])
    Date.new(time.year, time.month)
  end
end
