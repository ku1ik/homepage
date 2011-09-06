def run(*args); end

load './config.ru'

require 'net/http'
require 'uri'
require 'cgi'

def download_link(label, filename=nil)
  %Q("#{label}":http://counter.sickill.net?f=http://drop.sickill.net/blog/#{filename || label})
end

def link_to(title, href, opts={})
  p title
  p href
  p opts
  1/0 # raise hell if link_to used!
end

def image(thumb_href, normal_href, desc="")
  normal_href
end

def send_post(post)
  title = post.meta[:title]
  tags = post.meta[:tags].join(',')
  date = (post.meta[:date].utc - 7*3600).to_s.gsub('-', '/')
  body = post.instance_variable_get("@content")

  if post.meta[:img]
    body = "#{post.meta[:img]}\n\n#{body}"
  end

  if post.instance_variable_get("@processor") == RDiscount
    body = "<markdown>\n#{body}\n</markdown>"
  else
    body = post.compiled_content
  end

  url = URI.parse("http://posterous.com/api/2/sites/#{ENV['SITE_ID']}/posts")
  req = Net::HTTP::Post.new(url.path)
  req.basic_auth ENV['USER_EMAIL'], ENV['USER_PASS']

  form_data = {}
  form_data[:api_token] = ENV['API_TOKEN']

  form_data["post[title]"] = title
  form_data["post[body]"] = body
  form_data["post[tags]"] = tags
  form_data["post[display_date]"] = date

  req.set_form_data(form_data)

  res = Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }
  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    puts res.body
    puts '--------------------------------------------------------------------'
  else
    res.error!
  end
end

Post.all.each do |post|
  send_post(post)
end
