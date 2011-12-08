require File.expand_path('../test_helper', __FILE__)

describe "Renee::Bindings" do
  it "should allow the transformation of data" do
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
end