$: << File.expand_path("../../lib", File.dirname(__FILE__))
$: << File.dirname(__FILE__)
require 'renee'
require 'blog'
require 'json'

blog = Blog.new

run Renee {
  @blog = blog

  # find blog post and do things to it.
  var :integer do |id|
    @post = @blog.find_post(id)
    halt 404 unless @post
    path('edit').get.render! 'edit' # show editor
    get.render! 'show'              # show post
    delete do
      @post.delete!
      redirect! "/"
    end
    put do
      @post.title = request['title']       if request['title']
      @post.contents = request['contents'] if request['contents']
      redirect! "/#{@post.id}"
    end
  end

  post do
    halt :bad_request, "No title specified"    unless request['title']
    halt :bad_request, "No contents specified" unless request['contents']
    post = @blog.new_post(request['title'], request['contents'])
    redirect! "/#{post.id}"
  end

  get do
    case extension
    when 'json' then halt @blog.posts.map { |p| {:contents => p.contents} }.to_json
    else             render! 'index'
    end
  end
}.setup {
  use Rack::Lint
  use Rack::MethodOverride
  views_path File.expand_path(File.dirname(__FILE__) + "/views")
}
