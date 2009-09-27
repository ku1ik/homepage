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
