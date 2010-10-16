module BasicHelpers
  def link_to(title, href, opts={})
    tag(:a, title, opts.merge(:href => href))
  end

  def image_tag(src, desc="", opts={})
    tag(:img, opts.merge(:src => src, :alt => desc))
  end

  def image(thumb_href, normal_href, desc="")
    link_to(image_tag(thumb_href, desc), normal_href, :title => desc, :rel => "lightbox")
  end

  def partial(name)
    erb :"_#{name}", :layout => false
  end

  def linkified_tags(tags)
    tags.map { |t| link_to(t, "/blog/tag/#{t}") }.join(", ")
  end

  def linkified_years
    unique_years = Post.all.map { |p| p.meta[:date].year }.sort.uniq
    unique_years.map { |y| link_to(y, "/blog/#{y}", :class => "year") }.join(", ")
  end

  def posts_by_month(posts)
    groupped = posts.group_by { |post| post.meta[:date].month }
    groupped.keys.sort.inject({}) { |h,month| h[Date::MONTHNAMES[month]] = groupped[month]; h }
  end

  def download_link(label, filename=nil)
    %Q("#{label}":http://counter.sickill.net?f=http://drop.sickill.net/blog/#{filename || label})
  end
end
