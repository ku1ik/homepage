class Array
  def blank?
    empty?
  end
end

class NilClass
  def blank?
    true
  end
end

class Nanoc3::Item
  def tags
    self[:tags] && self[:tags].split(",").map { |t| t.strip }.sort || []
  end

  def created_at
    Time.parse(self[:created_at])
  end
end
