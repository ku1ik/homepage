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
