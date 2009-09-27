class Nanoc3::Item
  def tags
    self[:tags] && self[:tags].split(",").sort.map { |t| t.strip } || []
  end
  
  def path
    reps.first.path
  end
  
  def created_at
    Time.parse(self[:created_at])
  end
  
  def content
    reps.first.content_at_snapshot(:pre)
  end
end