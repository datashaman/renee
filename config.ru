require 'renee'
require 'haml'
require 'rdiscount'
require 'rack/codehighlighter'
require 'rack/google-analytics'
require 'coderay'

views = Dir[File.expand_path('../site/views/*.md', __FILE__)].map { |f| f[/\/([^\/]+)\.md/, 1] }
use Rack::Static, :urls => ['/css', '/img', '/doc'], :root => 'site/public'
use Rack::Codehighlighter, :coderay, :element => "pre>code", :pattern => /\A:::(\w+)\s*\n/
use Rack::GoogleAnalytics, :tracker => 'UA-26317661-1'
run Renee {
  path('concept') { redirect! '/' }
  views.each { |view|
    path = view == 'index' ? '' : view
    path("/#{path}").get {
      title = (view == 'index') ? '' : " &mdash; #{view.split('-').join(' ')}"
      render! view, :locals => {:title_part => title }
    }
  }
}.setup {
  views_path File.expand_path('../site/views', __FILE__)
  default_layout 'layouts/app'
}
