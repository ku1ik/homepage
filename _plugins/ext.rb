module Jekyll

  # monkey-patched to add date_year

  class Post
    # Convert this post into a Hash for use in Liquid templates.
    #
    # Returns <Hash>
    def to_liquid
      self.data.deep_merge({
        "title"      => self.data["title"] || self.slug.split('-').select {|w| w.capitalize! || w }.join(' '),
        "url"        => self.url,
        "date"       => self.date,
        "date_year"  => self.date.year,
        "id"         => self.id,
        "categories" => self.categories,
        "next"       => self.next,
        "previous"   => self.previous,
        "tags"       => self.tags,
        "content"    => self.content })
    end
  end
end
