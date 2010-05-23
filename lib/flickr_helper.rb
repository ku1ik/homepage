module FlickrHelper
  def image(thumb, normal, desc="")
    %(<a href="#{normal}" title="#{desc}"><img src="#{thumb}" alt="#{desc}" /></a>)
  end
end

Webby::Helpers.register(FlickrHelper)
