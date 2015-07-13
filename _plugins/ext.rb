module Jekyll

  # monkey-patched to add date_year

  class Post
    # Convert this post into a Hash for use in Liquid templates.

    def to_liquid(attrs = nil)
      further_data = Hash[(attrs || self.class::ATTRIBUTES_FOR_LIQUID).map { |attribute|
        [attribute, send(attribute)]
      }]

      further_data["date_year"] = further_data["date"].year

      data.deep_merge(further_data)
    end
  end

end
