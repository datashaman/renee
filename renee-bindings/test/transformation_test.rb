require File.expand_path('../test_helper', __FILE__)

describe "Renee::Bindings" do
  before {
    Renee::Bindings.reset!
  }

  it "should allow trasnfer of attrs" do
    data = {
      :json => '{"title":"Bible"}',
      :ruby => OpenStruct.new(:title => 'Bible'),
      :hash => {:title => "Bible"}
    }
    Renee::Bindings.object_binding(:book) { attr :title }
    bind = Renee::Bindings.bind_object(:book)
    assert_data_binding(bind, data)
  end
  
  it "should allow binding to lists of literals" do
    data = {
      :json => '["one","two","three"]',
      :ruby => %w(one two three),
      :hash => ['one', 'two', 'three']
    }
    Renee::Bindings.literal_binding(:number_word) { string ['one', 'two', 'three'] }
    bind = Renee::Bindings.bind_list(:number_word)
    assert_data_binding(bind, data)
  end
  
  it "should allow trasnfer of objects" do
    data = {
      :json => '{"name":"nathan","favorite_book":{"title":"Bible"}}',
      :ruby => OpenStruct.new(:name => "nathan", :favorite_book => OpenStruct.new(:title => "Bible")),
      :hash => {:name => "nathan", :favorite_book => {:title => "Bible"}}
    }
    Renee::Bindings.object_binding(:person) {
      attr :name
      object :favorite_book, :book
    }
    Renee::Bindings.object_binding(:book) { attr :title }
    bind = Renee::Bindings.bind_object(:person)
    assert_data_binding(bind, data)
  end
  
  it "should allow trasnfer of ints" do
    data = {
      :json => '{"name":"nathan","age":23}',
      :ruby => OpenStruct.new(:name => "nathan", :age => 23),
      :hash => {:name => "nathan", :age => 23}
    }
    Renee::Bindings.object_binding(:person) {
      attr :name
      int :age
    }
    bind = Renee::Bindings.bind_object(:person)
    assert_data_binding(bind, data)
  end
  
  it "should allow trasnfer of floats" do
    data = {
      :json => '{"name":"nathan","height":23.9}',
      :ruby => OpenStruct.new(:name => "nathan", :height => 23.9),
      :hash => {:name => "nathan", :height => 23.9}
    }
    Renee::Bindings.object_binding(:person) {
      attr :name
      float :height
    }
    bind = Renee::Bindings.bind_object(:person)
    assert_data_binding(bind, data)
  end
  
  it "should allow trasnfer of lists" do
    data = {
      :json => '{"name":"nathan","favorite_books":[{"title":"Bible"}]}',
      :ruby => OpenStruct.new(:name => "nathan", :favorite_books => [OpenStruct.new(:title => "Bible")]),
      :hash => {:name => "nathan", :favorite_books => [{:title => "Bible"}]}
    }
    Renee::Bindings.object_binding(:author) { attr :name; list :favorite_books, :book }
    Renee::Bindings.object_binding(:book) { attr :title }
    bind = Renee::Bindings.bind_object(:author)
    assert_data_binding(bind, data)
  end
  
  it "should allow wrapping of objects" do
    data = '{"name":"nathan","favorite_book":{"title":"Bible"}}'
    Renee::Bindings.object_binding(:author) { attr :name; object :favorite_book, :books }
    Renee::Bindings.object_binding(:book) { attr :title }
    j = Renee::Bindings.bind(:book).wrap_json(data)
    assert_equal "nathan", j.get(:name)
    assert_equal "Bible", j.get_object(:favorite_book).get(:title)
  end
  
  it "should support loading from a path" do
    File.open('/tmp/jjj', "w") { |f| f << '{"name":"nathan","favorite_book":{"title":"Bible"}}' }
    Renee::Bindings.object_binding(:author) { attr :name; object :favorite_book, :book }
    Renee::Bindings.object_binding(:book) { attr :title }
    r = Renee::Bindings.bind_object(:author).from_json_file('/tmp/jjj').as_ruby
    assert_equal "nathan", r.name
    assert_equal "Bible", r.favorite_book.title
  end
end