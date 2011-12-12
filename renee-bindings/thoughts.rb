# so ..

class JsonAdapter
  
end

class Object
  get       :nil => true | false (false by default)
  
  keys

  key?
  unset
end

module BindingsObject
  get_list
  get_obj
  get_int
  get_float
  get_bool
  get_str
  set_list
  set_obj
  set_int
  set_float
  set_bool
  set_str
end

class List
  get       :nil => true | false (false by default)
  get_list
  get_obj
  get_int
  get_float
  get_bool
  get_str
  size
  set
  unset
end

# binding ....
# 
#   binding for object
#   binding for literal
#   binding for array
#   
# only three kinds
# 
#   create a list binding
#   create an object binding
#   create a literal binding
# 
# list_binding(:list_of_book)
# list_binding
# 
# list of object ..
# list of literals
#  ... both take a binding, but implicitly create lists
#  
# all bindings can be inline or declared
# 
# bind_object
# bind_list()
# 
# 
# creates an implicit list binding
# 

