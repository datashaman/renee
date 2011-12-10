require File.expand_path('../test_helper', __FILE__)

describe "Renee::Bindings" do
  it "should allow trasnfer of attrs" do
    data = {
      :json => '{"title":"Bible"}',
      :ruby => OpenStruct.new(:title => "Bible"),
      :hash => {:title => "Bible"}
    }
    Renee::Bindings.binding(:books) { attr :title }
    bind = Renee::Bindings.bind_object(:books)
    assert_equal data[:json], bind.from_ruby(data[:ruby]).as_json
    assert_equal data[:hash], bind.from_ruby(data[:ruby]).as_hash
    assert_equal data[:ruby], bind.from_json(data[:json]).as_ruby
    assert_equal data[:hash], bind.from_json(data[:json]).as_hash
    assert_equal data[:ruby], bind.from_hash(data[:hash]).as_ruby
    assert_equal data[:json], bind.from_hash(data[:hash]).as_json
  end

  it "should allow trasnfer of objects" do
    data = {
      :json => '{"name":"nathan","favorite_book":{"title":"Bible"}}',
      :ruby => OpenStruct.new(:name => "nathan", :favorite_book => OpenStruct.new(:title => "Bible")),
      :hash => {:name => "nathan", :favorite_book => {:title => "Bible"}}
    }
    Renee::Bindings.binding(:author) { attr :name; object :favorite_book, :book }
    Renee::Bindings.binding(:book) { attr :title }
    bind = Renee::Bindings.bind_object(:author)
    assert_equal data[:json], bind.from_ruby(data[:ruby]).as_json
    assert_equal data[:json], bind.from_hash(data[:hash]).as_json
    assert_equal data[:ruby], bind.from_json(data[:json]).as_ruby
    assert_equal data[:ruby], bind.from_hash(data[:hash]).as_ruby
    assert_equal data[:hash], bind.from_json(data[:json]).as_hash
    assert_equal data[:hash], bind.from_ruby(data[:ruby]).as_hash
  end
  
  it "should allow wrapping of objects" do
    data = '{"name":"nathan","favorite_book":{"title":"Bible"}}'
    Renee::Bindings.binding(:author) { attr :name; object :favorite_book, :books }
    Renee::Bindings.binding(:book) { attr :title }
    j = Renee::Bindings.bind(:book).wrap_json(data)
    assert_equal "nathan", j.get(:name)
    assert_equal "Bible", j.get_object(:favorite_book).get(:title)
  end
  
  it "should support loading from a path" do
    File.open('/tmp/jjj', "w") { |f| f << '{"name":"nathan","favorite_book":{"title":"Bible"}}' }
    Renee::Bindings.binding(:author) { attr :name; object :favorite_book, :book }
    Renee::Bindings.binding(:book) { attr :title }
    r = Renee::Bindings.bind_object(:author).from_json_file('/tmp/jjj').as_ruby
    assert_equal "nathan", r.name
    assert_equal "Bible", r.favorite_book.title
  end

end