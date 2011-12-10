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