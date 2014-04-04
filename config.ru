DEFAULTLANG = 'ru'

# see http://randomerrata.com/post/56163474367/middleman-on-heroku

require "rubygems"

require "rack"
require "middleman/rack"
require "rack/contrib/try_static"
require 'rack/rewrite'
require 'rack/cors'

# allow all origins
use Rack::Cors do
  allow do
    origins '*'
    resource '*', 
        :headers => :any, 
        :methods => [:get, :post, :options]
  end
end

LANG = ENV['DMLANG'] || DEFAULTLANG

to_go = {}
Dir.glob('source/chapters/'+LANG+'/*.md.erb').each do |file|
  chapter = file.match('/([^/-]*)-.*$')[1]
  to_go[chapter] = `grep -o '////' #{file} | wc -l`.to_i
end

# Build the static site when the app boots

to_go_str = to_go.map {|k,v| "#{k}:#{v}"}.join(',')
p to_go_str
puts `TOGO='#{to_go_str}' bundle exec middleman build`

# Enable proper HEAD responses
use Rack::Head

# Attempt to serve static HTML files
use Rack::TryStatic,
    :root => "tmp",
    :urls => %w[/],
    :try => ['.html', 'index.html', '/index.html']

# Serve a 404 page if all else fails
run lambda { |env|
  [
    404,
    {
      "Content-Type"  => "text/html",
      "Cache-Control" => "public, max-age=60"
    },
    File.open("tmp/404/index.html", File::RDONLY)
  ]
}