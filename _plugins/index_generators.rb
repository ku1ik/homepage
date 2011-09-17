module Jekyll

  class IndexGenerator < Generator
    safe true

    def generate(site)
      if site.layouts.key? 'year_index'
        site.posts.map { |p| p.date.year }.uniq.each do |year|
          write_index(site, year.to_s, year, 'year_index.html')
        end
      end

      if site.layouts.key? 'tag_index'
        site.tags.keys.each do |tag|
          write_index(site, File.join('topics', tag.to_s), tag, 'tag_index.html')
        end
      end
    end

    def write_index(site, dir, subject, template_name)
      index = IndexPage.new(site, site.source, dir, subject, template_name)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.pages << index
    end

    class IndexPage < Page
      def initialize(site, base, dir, subject, template_name)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)
        self.read_yaml(File.join(base, '_layouts'), template_name)
        self.data['header'].gsub!('{{subject}}', subject.to_s) if data['header']
        self.data['subject'] = subject
        self.data['title'] = subject
      end
    end
  end

end
