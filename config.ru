require 'rack/contrib/try_static'

# Rack::Mime::MIME_TYPES.merge!({
#   '.eot'  => 'application/vnd.ms-fontobject',
#   '.ttf'  => 'font/font',
#   '.otf'  => 'font/opentype',
#   '.woff' => 'font/x-woff'
# })

ROOT = "_site"

use Rack::TryStatic,
  :root => ROOT, # static files root dir
  :urls => %w[/], # match all requests
  :try => ['.html', 'index.html', '/index.html'], # try these postfixes sequentially
  :index => 'index.html',
  :cache_control => 'public, max-age=300'

run lambda { |env|
  not_found_page = "#{ROOT}/404.html"

  if File.exist?(not_found_page)
    body = File.open(not_found_page, File::RDONLY)
  else
    body = ['404 - page not found']
  end

  [404, { 'Content-Type' => 'text/html' }, body]
}
