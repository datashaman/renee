require File.expand_path('../test_helper', __FILE__)

describe "Renee::Bindings" do
  it "should allow trasnfer of attrs" do
    data = {
      :json => '{"title":"Bible"}',
      :ruby => OpenStruct.new(:title => "Bible"),
      :hash => {:title => "Bible"}
    }
    Renee::Bindings.binding(:books) { attr :title }
    assert_equal data[:json], Renee::Bindings.from_ruby(data[:ruby]).bind_with(:books).as_json
    assert_equal data[:json], Renee::Bindings.from_hash(data[:hash]).bind_with(:books).as_json
    assert_equal data[:ruby], Renee::Bindings.from_json(data[:json]).bind_with(:books).as_ruby
    assert_equal data[:ruby], Renee::Bindings.from_hash(data[:hash]).bind_with(:books).as_ruby
    assert_equal data[:hash], Renee::Bindings.from_json(data[:json]).bind_with(:books).as_hash
    assert_equal data[:hash], Renee::Bindings.from_ruby(data[:ruby]).bind_with(:books).as_hash
  end

  it "should allow trasnfer of objects" do
    data = {
      :json => '{"name":"nathan","favorite_book":{"title":"Bible"}}',
      :ruby => OpenStruct.new(:name => "nathan", :favorite_book => OpenStruct.new(:title => "Bible")),
      :hash => {:name => "nathan", :favorite_book => {:title => "Bible"}}
    }
    Renee::Bindings.binding(:authors) { attr :name; object :favorite_book, :books }
    Renee::Bindings.binding(:books) { attr :title }
    assert_equal data[:json], Renee::Bindings.from_ruby(data[:ruby]).bind_with(:authors).as_json
    assert_equal data[:json], Renee::Bindings.from_hash(data[:hash]).bind_with(:authors).as_json
    assert_equal data[:ruby], Renee::Bindings.from_json(data[:json]).bind_with(:authors).as_ruby
    assert_equal data[:ruby], Renee::Bindings.from_hash(data[:hash]).bind_with(:authors).as_ruby
    assert_equal data[:hash], Renee::Bindings.from_json(data[:json]).bind_with(:authors).as_hash
    assert_equal data[:hash], Renee::Bindings.from_ruby(data[:ruby]).bind_with(:authors).as_hash
  end

  it "should allow wrapping of objects" do
    data = '{"name":"nathan","favorite_book":{"title":"Bible"}}'
    Renee::Bindings.binding(:authors) { attr :name; object :favorite_book, :books }
    Renee::Bindings.binding(:books) { attr :title }
    j = Renee::Bindings.wrap(:json, data)
    assert_equal "nathan", j.get_attr(:name)
    assert_equal "Bible", j.get_object(:favorite_book).get_attr(:title)
  end

  it "should support loading from a path" do
    File.open('/tmp/jjj', "w") { |f| f << '{"name":"nathan","favorite_book":{"title":"Bible"}}' }
    Renee::Bindings.binding(:authors) { attr :name; object :favorite_book, :books }
    Renee::Bindings.binding(:books) { attr :title }
    j = Renee::Bindings.from_json_file('/tmp/jjj')
    assert_equal "nathan", j.get_attr(:name)
    assert_equal "Bible", j.get_object(:favorite_book).get_attr(:title)
  end

end