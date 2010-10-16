# This code was taken from Nanoc's Blogging helpers module (http://github.com/ddfreyne/nanoc/blob/master/lib/nanoc3/helpers/blogging.rb)

module AtomHelper
  def atom_feed(params={})
    require 'builder'
    require 'time'

    # Extract parameters
    limit             = params[:limit] || 5
    relevant_articles = params[:articles] || articles || []
    content_proc      = params[:content_proc] || lambda { |a| a.compiled_content(binding) }
    excerpt_proc      = params[:excerpt_proc] || lambda { |a| a[:excerpt] }

    # Check config attributes
    if @site.config[:base_url].nil?
      raise RuntimeError.new('Cannot build Atom feed: site configuration has no base_url')
    end

    # Check feed item attributes
    title = params[:title] || @item[:title] || @site.config[:title]
    if title.nil?
      raise RuntimeError.new('Cannot build Atom feed: no title in params, item or site config')
    end
    author_name = params[:author_name] || @item[:author_name] || @site.config[:author_name]
    if author_name.nil?
      raise RuntimeError.new('Cannot build Atom feed: no author_name in params, item or site config')
    end
    author_uri = params[:author_uri] || @item[:author_uri] || @site.config[:author_uri]
    if author_uri.nil?
      raise RuntimeError.new('Cannot build Atom feed: no author_uri in params, item or site config')
    end

    # Check article attributes
    if relevant_articles.empty?
      raise RuntimeError.new('Cannot build Atom feed: no articles')
    end
    if relevant_articles.any? { |a| a[:created_at].nil? }
      raise RuntimeError.new('Cannot build Atom feed: one or more articles lack created_at')
    end

    # Get sorted relevant articles
    sorted_relevant_articles = relevant_articles.sort_by do |a|
      attribute_to_time(a[:created_at])
    end.reverse.first(limit)

    # Get most recent article
    last_article = sorted_relevant_articles.first

    # Create builder
    buffer = ''
    xml = Builder::XmlMarkup.new(:target => buffer, :indent => 2)

    # Build feed
    xml.instruct!
    xml.feed(:xmlns => 'http://www.w3.org/2005/Atom') do
      root_url = @site.config[:base_url] + '/'

      # Add primary attributes
      xml.id      root_url
      xml.title   title

      # Add date
      xml.updated(attribute_to_time(last_article[:created_at]).to_iso8601_time)

      # Add links
      xml.link(:rel => 'alternate', :href => root_url)
      xml.link(:rel => 'self',      :href => feed_url)

      # Add author information
      xml.author do
        xml.name  author_name
        xml.uri   author_uri
      end

      # Add articles
      sorted_relevant_articles.each do |a|
        # Get URL
        url = url_for(a)
        next if url.nil?

        xml.entry do
          # Add primary attributes
          xml.id        atom_tag_for(a)
          xml.title     a[:title], :type => 'html'

          # Add dates
          xml.published attribute_to_time(a[:created_at]).to_iso8601_time
          xml.updated   attribute_to_time(a[:updated_at] || a[:created_at]).to_iso8601_time

          # Add specific author information
          if a[:author_name] || a[:author_uri]
            xml.author do
              xml.name  a[:author_name] || author_name
              xml.uri   a[:author_uri]  || author_uri
            end
          end

          # Add link
          xml.link(:rel => 'alternate', :href => url)

          # Add content
          summary = excerpt_proc.call(a)
          xml.content   content_proc.call(a), :type => 'html'
          xml.summary   summary, :type => 'html' unless summary.nil?
        end
      end
    end

    buffer
  end

  def attribute_to_time(time)
    time = Time.local(time.year, time.month, time.day) if time.is_a?(Date)
    time = Time.parse(time) if time.is_a?(String)
    time
  end

  def feed_url
    # Check attributes
    if @site.config[:base_url].nil?
      raise RuntimeError.new('Cannot build Atom feed: site configuration has no base_url')
    end

    @site.config[:base_url] + "/"
  end

  def url_for(item)
    # Check attributes
    if @site.config[:base_url].nil?
      raise RuntimeError.new('Cannot build Atom feed: site configuration has no base_url')
    end

    # Build URL
    if item[:custom_url_in_feed]
      item[:custom_url_in_feed]
    elsif item[:custom_path_in_feed]
      @site.config[:base_url] + item[:custom_path_in_feed]
    elsif item.path
      @site.config[:base_url] + item.path
    end
  end

  def atom_tag_for(item)
    require 'time'

    hostname, base_dir = %r{^.+?://([^/]+)(.*)$}.match(@site.config[:base_url])[1..2]

    formatted_date = attribute_to_time(item[:created_at]).to_iso8601_date

    'tag:' + hostname + ',' + formatted_date + ':' + base_dir + (item.path || item.identifier)
  end
end
