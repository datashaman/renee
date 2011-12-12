require File.expand_path('../test_helper', __FILE__)

#describe "Renee::Bindings" do
#  before {
#    Renee::Bindings.reset!
#  }
#
#  it "should allow binding to specific classes" do
#    data = {
#      :json => '{"name":"nathan"}',
#      :ruby => OpenStruct.new(:name => "nathan"),
#      :hash => {:name => "nathan"}
#    }
#    person = Class.new(Struct.new(:name)) { def say_name; "My name is #{name}"; end }
#    Renee::Bindings.object_binding(:person) { attr :name }
#    Renee::Bindings.set_ruby_generator(:person) { |attrs| person.new(attrs[:name]) }
#    bind = Renee::Bindings.bind_object(:person)
#    p bind.from_json(data[:json]).as_ruby
#    assert_equal "My name is nathan", bind.from_json(data[:json]).as_ruby.say_name
#  end
#
#end