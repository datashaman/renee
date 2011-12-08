$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'renee_bindings'
{
  :name => "nathan",
  :books => {:title => 'bible'}
}

Person = Struct.new(:name, :books)
Book = Struct.new(:title)

#roughly analogous 

Renee::Bindings.binding(:books) do
  attr :title
  attr :year
end

Renee::Bindings.binding(:people) do 
  attr :name
  attr :books, :binding => :books
end

#from to wrap them ..

#uniform attribute reader/writer

#nathan = Person.new(:name=>'nathan', :books => [Book.new("bible")])
#str = person_binding.from_ruby(nathan).as_json
#p str
#p person_binding.from_json(str).to(Person)
#p .bind_with(person_binding).as_json_s

data = {:name => 'nathan', :books => [{:title => 'bible', :year => 1999}, {:title => 'koran', :year => 2011}]}

input = Renee::Bindings.from_hash(data).bind_with(:people)
#puts input.as_json
puts "----"
puts input.as_ruby.inspect
puts input.as_json.inspect

# # JSON sematics:
# 
# 
# # factory
# 
# # class methods:
# 
# create_list
# create_object
# 
# # instance methods:
# 
# list?
# set_attr
# get_attr
# set_list_item
# get_list_item