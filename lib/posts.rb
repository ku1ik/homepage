def render_post_header(post)
  html = ""
  html << %(<h2>#{link_to post[:title], post.path}</h2>)
  html << %(<div class="article-info">)
  html << %(-- posted on #{post.created_at.strftime("%d %b %Y")}, )
  html << %(tagged with #{post.tags.map { |t| link_to(t, "/blog/tag/#{t}") }.join(", ")} --)
  html << %(</div>)
end

def render_post(post, opts={}, &blk)
  html = ""
  html << %(<div class="article">)
  html << render_post_header(post)
  html << %(  <br class="clear" />)
  html << %(<div class="article-content">)
  html << (block_given? ? capture(&blk) : post.content)
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
  
def months_and_items(items=nil)
  @items = items unless items.nil?
  articles.group_by do |p|
    time = Time.parse(p[:created_at])
    Date.new(time.year, time.month)
  end
end
