module Sickill
  module Filters

    def uniq(arg)
      arg.uniq
    end

    def collect(items, pattern)
      [*items].map do |item|
        pattern.gsub('[item]', item.to_s)
      end
    end
  end
end

Liquid::Template.register_filter(Sickill::Filters)
