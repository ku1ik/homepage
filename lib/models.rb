class Post
  attr_reader :title, :content, :slug, :meta, :content

  def self.all
    if @all.nil? || ENV['RACK_ENV'] != 'production'
      @all = Dir["content/blog/*"].map { |filename| Post.new(filename) }.reject { |p| p.meta[:draft] }
      @all = @all.sort_by { |p| p.meta[:date] }.reverse
    end

    @all
  end

  def self.find_by_tag(tag)
    all.select { |p| p.meta[:tags].include?(tag) }
  end

  def self.find_by_year(year)
    all.select { |p| p.meta[:date].year == year }
  end

  def self.find_by_slug(slug)
    all.detect { |p| p.slug == slug }
  end

  def self.recent(num)
    all[0..num]
  end

  def initialize(filename)
    @path = filename
    filename =~ /\d{4}-\d{2}-\d{2}-(.+)\.(.+)/
    @slug, @ext = $1, $2
    @processor = case @ext
              when "txt", "textile"
                RedCloth
              when "md", "markdown"
                RDiscount
              end
    data = File.read(filename)
    meta, @content = data.split("\n\n", 2)
    @meta = YAML.load(meta).inject({}) { |h, keyvalue| h[keyvalue[0].to_sym] = keyvalue[1]; h }
    @meta[:date] = Time.parse(@meta[:date]) if @meta[:date]
    @meta[:tags] = @meta[:tags] && @meta[:tags].split(/,\s*/).sort || []
    @title = @meta[:title]
  end

  def compiled_content(_binding=nil)
    erb_output = ERB.new(@content).result(_binding || binding)
    @processor.new(erb_output).to_html
  end

  def route
    @path =~ /(\d{4})-(\d{2})-(\d{2})-(.+)\./
    "/blog/#$1/#$2/#$3/#$4.html"
  end

  alias_method :path, :route

  def [](key)
    if key == :created_at
      key = :date
    end
    meta[key]
  end
end
