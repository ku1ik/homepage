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
  html << %(<div class="section">) # open section

  html << %(<div class="article">)
  # header
  html << render_post_header(post)
  html << %(  <br class="clear" />)
  # content
  html << %(<div class="article-content">)
  html << (block_given? ? capture(&blk) : post.content)
  html << %(</div>) # close article-content
  html << %(</div>) # close article
  if !opts[:comments]
    html << link_to("View Comments", post.path + "#disqus_thread")
  end
  
  # related posts
  if opts[:comments] && !(related = related_articles(@item)).empty?
    html << %(</div><div class="section">) # close and reopen section
    html << %(<div class="related">)
    html << %(<p>Somewhat related articles:</p>)
    html << %(<ul>)
    related.each do |a|
      html << %(<li>#{link_to a[:title], a.path}</li>)
    end
    html << %(</ul>)
    html << %(</div>) # close related
  end
  
  # comments
  if opts[:comments]
    html << %(</div><div class="section">) # close and reopen section
    html << %(<div id="disqus_thread"></div><script type="text/javascript" src="http://disqus.com/forums/sickill/embed.js"></script><noscript><a href="http://sickill.disqus.com/?url=ref">View the discussion thread.</a></noscript><a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>)
  end
  
  html << %(</div>) # close section
  
  # Append to erbout if we have a block
  if block_given?
    erbout = eval('_erbout', blk.binding)
    erbout << html
  end
  
  # return result
  html
end
  
def articles_by_month
  sorted_articles.group_by do |p|
    time = Time.parse(p[:created_at])
    Date.new(time.year, time.month)
  end
end

def articles_for_month(date)
  articles_by_month[date]
end

def articles_by_tag
  sorted_articles.inject(Hash.new { |h,k| h[k] = [] }) do |acc, a|
    a.tags.each do |t| 
      acc[t] << a
    end
    acc
  end
end

def articles_for_tag(tag)
  sorted_articles.select { |a| a.tags.include?(tag) }
end

def related_articles(item, number=3)
  matches = []
  articles.reject { |a| a == item }.each do |a|
    if !item.tags.blank? && !a.tags.blank?
      common_tags = item.tags & a.tags
      if common_tags.size >= 2
        matches << [common_tags, a]
        # p common_tags
      end
    end
  end
  best_matching = matches.sort_by { |m| -m.first.size }[0..2].map { |m| m[1] }
  # p best_matching.map { |bm| bm[:title] }
  # best_matching
end
