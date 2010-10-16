class Time
  def to_iso8601_date
    self.strftime("%Y-%m-%d")
  end

  def to_iso8601_time
    self.gmtime.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
end
