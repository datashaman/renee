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
    path('edit') { puts "showing edit!"; render! 'edit' }
    get { puts "show."; render! 'show' }
    delete { @post.delete!; halt :ok }
    put {
      @post.title = request['title'] if request['title']
      @post.contents = request['contents'] if request['contents']
      halt :ok
    }
  end

  post {
    if request['title'] && request['contents']
      @blog.new_post(request['title'], request['contents'])
      halt :created
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