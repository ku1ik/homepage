def image(thumb, normal, desc="")
  %(<a href="#{normal}" title="#{desc}">#{image_tag(thumb, desc)}</a>)
end

def image_tag(src, desc="")
  %(<img src="#{src}" alt="#{desc}" />)
end

