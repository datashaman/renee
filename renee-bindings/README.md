# Data binding

Working so far:

    require 'renee-bindings'
    {
      :name => "nathan",
      :books => {:title => 'bible'}
    }

    Person = Struct.new(:name, :books)
    Book = Struct.new(:title)

    #roughly analogous 

    Bound::DefaultFactory.binding(:book) do
      attr :title
      attr :year
    end

    Bound::DefaultFactory.binding(:person) do 
      attr :name
      list :books, :book
    end

    data = {:name => 'nathan', :books => [{:title => 'bible', :year => 1999}, {:title => 'koran', :year => 2011}]}

    input = Bound::DefaultFactory.from_hash(data).bind_with(:person)
    puts "----"
    puts input.to_ruby.inspect
    puts input.to_json.inspect

    # ----
    # #<OpenStruct name="nathan", books=[#<OpenStruct title="bible", year=1999>, #<OpenStruct title="koran", year=2011>]>
    # {:name=>"nathan", :books=>[{:title=>"bible", :year=>1999}, {:title=>"koran", :year=>2011}]}
