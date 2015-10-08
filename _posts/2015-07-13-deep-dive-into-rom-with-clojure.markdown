---
title: Deep Dive Into ROM... With Clojure
layout: post
tags:
  - ruby
  - clojure
---

Recently I read the slides of
[Deep Dive Into ROM](https://speakerdeck.com/solnic/deep-dive-into-rom), the
latest talk by Piotr Solnica. It's a great talk about how
[ROM](http://rom-rb.org/) is built and what are the main principles behind its
implementation. While reading the Ruby code presented on the slides, code that
is very functional in nature, with focus on immutability, I started realizing
how close all of this was to a code one could write in Clojure. Let's look at
some examples.

On slide 9 we can see the following Ruby code:

```ruby
class Thing
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def with(value)
    self.class.new(value)
  end
end

thing = Thing.new(1)
other = thing.with(2)
```

Here Piotr is implementing an immutable object, with handy `with` method for
getting a modified version of the object. The original `thing` object is never
modified.

One of the many great things about Clojure is its immutable, persistent data
structures. Let's look at the snippets below:

```clojure
(conj '(1 2 3) 4) ; => '(4 1 2 3)
(conj [1 2 3] 4) ; => [1 2 3 4]
(conj {:a 1, :b 2} {:a 5}) ; => {:b 2, :a 5}
(conj #{:a :b} :c) ; => #{:c :b :a}
```

[conj](http://clojuredocs.org/clojure.core/conj) is a function which adds a new
element to a given collection. Here we add new elements to a list, vector, map
and set. The input collection stays unmodified and you get a new one, which
shares its structure (previous elements) with the original one.

`Thing` class example from Ruby could be as simple as this in Clojure:
    
```clojure
(def thing {:value 1})
(def other (conj thing {:value 2}))
```
    
Let's jump to the slide 11 of the presentation, containing the following code:
    
```ruby
class AddTo
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def call(other)
    other + value
  end
end

add_to = AddTo.new(1)

add_to.call(1) # => 2
add_to.call(2) # => 3
```

This looks a lot like partial function application in functional languages. In
Clojure we can use [partial](http://clojuredocs.org/clojure.core/partial)
function to achieve similar effect:

```clojure
(defn add-to [value]
  (partial + value))

(def add-to-one (add-to 1))

(add-to-one 1) ; => 2
(add-to-one 2) ; => 3
```

Note, that `+` here isn't any special language keyword (operator). It is the
name of the function, that returns a sum of numbers. Thanks to this, we are able
to pass it as a function to other higher-order functions like `partial`.

Now let's look at slides 15 & 16, where we can see a usage of a class which
requires some collaborators and configuration:
    
```ruby
class StringTransformer
  attr_reader :executor, :operations

  def initialize(executor, operations)
    @executor = executor
    @operations = operations
  end

  def call(input)
    operations.reduce(input) { |a, e|
      executor.call(a, e)
    }
  end
end

executor = -> str, meth { str.send(meth) }
operations = [:upcase]

upcaser = StringTransformer.new(executor, operations)

upcaser.call('hello world') # => "HELLO WORLD"
```

This is how a Clojure equivalent could look like:

```clojure
(defn string-transformer [executor operations]
  (fn [input]
    (reduce executor input operations)))

(defn executor [str f]
  (f str))

(def operations [clojure.string/upper-case])

(def upcaser (string-transformer executor operations))

(upcaser "hello world") ; => "HELLO WORLD"
```

`string-transformer` function takes required collaborators (`executor`) and
configuration (`operations`) and returns a new function that takes one argument
and executes reduce operation with it.

Slide 18 shows how proc [currying](https://en.wikipedia.org/wiki/Currying) can
be used in Ruby:
    
```ruby
add = proc { |i, j| i + j }

add_to_one = add.curry.call(1)

add_to_one.call(2) # => 3
```

While Clojure doesn't have auto-curried functions (it prefers
[variadic functions](http://clojure-doc.org/articles/language/functions.html#variadic-functions))
this example can be approximated with partial application:

```clojure
(defn add [i j] (+ i j))

(def add-to-one (partial add 1))

(add-to-one 2) ; => 3
```

Or, even shorter:

```clojure
(def add-to-one (partial + 1))

(add-to-one 2) ; => 3
```

On slide 21 Piotr shows the same interface (`.[]`) for executing a default
operation (method) on objects of different types:
    
```ruby
add = proc { |i, j| i + j }

add[1, 2] # WEIRD?

hash = { a: 1 }
hash[:a] # less weird, right?

arr = [:a, :b]
arr[0] # less weird, right?
```

`add[1, 2]` doesn't feel natural in Ruby but it's consistent with hash and array
element access (the latter two feel very natural). Interestingly, Clojure's
syntax doesn't distinguish between calling a function and accessing an element
in a collection:

```clojure
(defn add [i j]
  (+ i j))

(add 1 2)

(def hash {:a 1})
(hash :a) ; => 1
(:a hash) ; => 1

(def arr [:a :b])
(arr 0) ; => :a
```

As you can see maps, vectors (also lists and sets) are functions too! They
implement `IFn` interface and thus are callable.

But wait, what about `(:a hash)` invocation? Keyword (called symbol in Ruby)
also implements `IFn` and can be used to lookup itself in a given map. This is
really useful when mapping on a collection of maps because you can pass a
keyword as a mapping function to [map](http://clojuredocs.org/clojure.core/map):

```clojure
(map :name [{:name "Jane" :age 30} {:name "John" :age 31}]) ; => ("Jane" "John")
```

Fast-forward to slide 33, we see procs, procs and even more procs:
    
```ruby
all_users = [
  { name: 'Jane', email: 'jane@doe.org' },
  { name: 'John', email: 'john@doe.org' }
]

User = Class.new(OpenStruct)

find_by_name = proc { |arr, name|
  arr.select { |el| el[:name] == name }
}

map_to_users = proc { |arr, name|
  arr.map { |el| User.new(el) }
}

users_by_name = proc { |arr, name|
  map_to_users[find_by_name[all_users, name]]
}

users_by_name[all_users, 'Jane'] # => [#<User name="Jane", email="jane@doe.org">]
```

So, functions, functions and even more functions in Clojure, right?

```clojure
(def all-users [{:name "Jane", :email "jane@doe.org" } {:name "John", :email "john@doe.org"}])

(defrecord User [name email])

(defn find-by-name [arr name]
  (filter #(= name (:name %)) arr))

(defn map-to-users [arr]
  (map #(->User (:name %) (:email %)) arr))

(defn users-by-name [arr name]
  (map-to-users (find-by-name arr name)))

(users-by-name all-users "Jane") ; => (User{:email "jane@doe.org", :name "Jane"})
```

Note that usage of Clojure's [record](http://clojure.org/datatypes) is a bit
artificial here but I left it to match the intent of the above Ruby code.

There's one more interesting (and highly functional) piece of code we can look
at. Slides 45-47 show this:

```ruby
class Users < ROM::Relation
  forward :select

  def by_name(name)
    select { |user| user[:name] == name }
  end
end

class Tasks < ROM::Relation
  forward :select

  def for_users(users)
    user_names = users.map { |user| user[:name] }
    select { |task| user_names.include?(task[:user]) }
  end
end

user_dataset = [
  { name: 'Jane', email: 'jane@doe.org' },
  { name: 'John', email: 'john@doe.org' }
]

task_dataset = [
  { user: 'Jane', title: 'Task One' },
  { user: 'John', title: 'Task Two' }
]

users = Users.new(user_dataset).to_lazy
tasks = Tasks.new(task_dataset).to_lazy

user_tasks = users.by_name >> tasks.for_users

user_tasks.call('Jane').to_a # => [{:user=>"Jane", :title=>"Task One"}]
```

The above code defines 2 relation classes, instantiates them with actual
datasets and combines them into a pipeline. The resulting pipeline can later be
called to get the result.

This is no different from function composition in functional programming.
Clojure has [comp](http://clojuredocs.org/clojure.core/comp) function we can
use:

```clojure
(def all-users [{:name "Jane", :email "jane@doe.org" } {:name "John", :email "john@doe.org"}])
(def all-tasks [{:user "Jane", :title "Task One"} {:user "John", :title "Task Two"}])    

(defn users-by-name [users name]
  (filter #(= name (:name %)) users))

(defn tasks-for-users [tasks users]
  (let [user-names (map :name users)]
    (filter #(some #{(:user %)} user-names) tasks)))

(def my-users-by-name (partial users-by-name all-users))
(def my-tasks-for-users (partial tasks-for-users all-tasks))
    
(def user-tasks (comp my-tasks-for-users my-users-by-name))

(user-tasks "Jane") ; => ({:title "Task One", :user "Jane"})
```

Here `my-users-by-name` and `my-tasks-for-users` functions are a result of
calling `partial` over `users-by-name` and `tasks-for-users` respectively.
They're parametrized with `all-users` and `all-tasks`, and can be seen as
equivalents of `users.by_name` and `tasks.for_users` from the Ruby example.

To translate Piotr's `users.by_name >> tasks.for_users` to Clojure we used
`comp` to compose these 2 functions into a new one, which when called calls the
first one with the result of the second one. Note that `comp` executes the
functions in reversed order (unlike Piotr's Ruby version which uses `>>`
operator to nicely visualize the data flow).

To sum up, if you
[feel that your code looks weird](https://twitter.com/sickill/status/618765702338625537),
then maybe it's time to look at other programming languages (not necessarily
Clojure). There's a good chance, that you will find one, that suits your current
way of thinking, allowing you to express your favourite problems in a simpler,
more concise way.
