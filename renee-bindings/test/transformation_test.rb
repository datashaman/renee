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
    Renee::Bindings.binding(:book) { attr :title }
    bind = Renee::Bindings.bind_object(:book)
    assert_data_binding(bind, data)
  end
  
  it "should allow trasnfer of objects" do
    data = {
      :json => '{"name":"nathan","favorite_book":{"title":"Bible"}}',
      :ruby => OpenStruct.new(:name => "nathan", :favorite_book => OpenStruct.new(:title => "Bible")),
      :hash => {:name => "nathan", :favorite_book => {:title => "Bible"}}
    }
    Renee::Bindings.binding(:person) {
      attr :name
      object :favorite_book, :book
    }
    Renee::Bindings.binding(:book) { attr :title }
    bind = Renee::Bindings.bind_object(:person)
    assert_data_binding(bind, data)
  end
  
  it "should allow trasnfer of ints" do
    data = {
      :json => '{"name":"nathan","age":23}',
      :ruby => OpenStruct.new(:name => "nathan", :age => 23),
      :hash => {:name => "nathan", :age => 23}
    }
    Renee::Bindings.binding(:person) {
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
    Renee::Bindings.binding(:person) {
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
    Renee::Bindings.binding(:author) { attr :name; list :favorite_books, :book }
    Renee::Bindings.binding(:book) { attr :title }
    bind = Renee::Bindings.bind_object(:author)
    assert_data_binding(bind, data)
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

  it "should allow binding to specific classes" do
    data = {
      :json => '{"name":"nathan"}',
      :ruby => OpenStruct.new(:name => "nathan"),
      :hash => {:name => "nathan"}
    }
    person = Class.new(Struct.new(:name)) { def say_name; "My name is #{name}"; end }
    Renee::Bindings.binding(:person) { attr :name }
    Renee::Bindings.bind_ruby_object(:person) { |attrs| person.new(attrs[:name]) }
    bind = Renee::Bindings.bind_object(:person)
    assert_equal "My name is nathan", bind.from_json(data[:json]).as_ruby.say_name
  end
end