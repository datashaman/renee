$: << File.expand_path("../../lib", File.dirname(__FILE__))
$: << File.dirname(__FILE__)
require 'renee'
require 'blog'
require 'json'

use Rack::MethodOverride

blog = Blog.new

run Renee {

  @blog = blog

  # find blog post and do things to it.
  var :integer do |id|
    @post = @blog.find_post(id)
    halt 404 unless @post
    path('edit') { render! 'edit' }

    get { render! 'show' }
    delete { @post.delete!; redirect! "/" }
    put {
      @post.title = request['title'] if request['title']
      @post.contents = request['contents'] if request['contents']
      redirect! "/#{@post.id}"
    }
  end

  post {
    if request['title'] && request['contents']
      post = @blog.new_post(request['title'], request['contents'])
      redirect! "/#{post.id}"
    else
      halt :bad_request
    end
  }

  get do
    case extension
    when 'json' then halt @blog.posts.map { |p| {:contents => p.contents} }.to_json
    else             render! 'index'
    end
  end
}.setup {
  views_path File.expand_path(File.dirname(__FILE__) + "/views")
}