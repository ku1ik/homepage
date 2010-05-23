module ArticleHelper
  def render_article2(article, &blk)
    full_article = block_given?
    puts "full_article = #{full_article}"
    out = %(<div class="#{full_article ? "article" : "article-preview"}">)
    out << %(<h2 class="article-title">)
    out << %(<a href="#{article.url}">#{article.title}</a>)
    out << %(</h2>)
    out << %(<div class="article-info">)
    out << %(Posted by <strong>Sickill</strong> on #{article.created_at.strftime("%b %d, %y")})
    out << %(</div>)
    if full_article
      out << %(<br class="clear" />)
      out << %(<div class="article-content">)
#      out << "\n\n#{capture_erb(&blk)}\n\n"
      out << %(</div>)
      out << %(<div id="disqus_thread"></div><script type="text/javascript" src="http://disqus.com/forums/sickill/embed.js"></script><noscript><a href="http://sickill.disqus.com/?url=ref">View the discussion thread.</a></noscript><a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>)
    end
    out << %(</div>)
    if full_article
      concat_erb(capture_erb(&blk), blk.binding)
      #concat_erb(out, blk.binding)
    else
      article.title
    end
  end
end

Webby::Helpers.register(ArticleHelper)
