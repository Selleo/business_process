⚠️ ATTENTION ⚠️

BusinessProcess gem is no longer supported, as it has been replaced by [rails-patterns](https://github.com/Selleo/pattern) gem, which includes more light-weight version of Service Object pattern 

# BusinessProcess

ServiceObject'a'like pattern

#### Setup 

```ruby
# Gemfile

gem 'business_process'
```

then `bundle`

#### Usage

```ruby
# Define business process

class DoSomething < BusinessProcess::Base
  # Specify requirements
  needs :some_method
  needs :some_other_method
  
  # Specify process (action)
  def call
    some_method + some_other_method
  end
end

# Execute using named parameters
DoSomething.call(some_method: 10, some_other_method: 20)

# Execute using parameter object
class Something
  def some_method
    10
  end 
  
  def some_other_method
    20
  end
end

DoSomething.call(Something.new)

# Read result of execution
service = DoSomething.call(Something.new)
service.result # => 30
service.success? # => true
```

#### Failing steps

To indicate failure of business process, use #fail method. Whatever you pass into the method, will be available through #error attribute on the business process object. If you pass a class that inherits from `Exception` it will also be raised.

```ruby
# Define business process

class DoSomething < BusinessProcess::Base
 # Specify requirements
 needs :some_method
 needs :some_other_method
 
 # Specify process (action)
 def call
   do_something
   do_something_else
 end
 
 private
 
 def do_something
   fail(:too_low) if some_method < 10 
 end
 
 def do_something_else
   some_other_method + 20
 end
end

# Execute using named parameters
DoSomething.call(some_method: 5, some_other_method: 20)


# Read result of execution
service = DoSomething.call(Something.new)
service.result # => 25
service.success? # => false
service.error # => :too_low
```


#### Process definition using .steps

```ruby
# Define business process

class DoSomething < BusinessProcess::Base
  # Specify requirements
  needs :some_method
  needs :some_other_method
  
  # Specify steps  
  steps :do_something,
        :do_something_else
  
  private
  
  def do_something
    @some_result = some_method + 10
  end
  
  def do_something_else
    some_other_method * 20 + @some_result 
  end  
end
```

#### Process definition using .steps and calling related service object

This is useful when some business processes can be composed of other business processes. Remember, that caller business process should provide `needs` for the callee business process.

```ruby
# Define business process

class DoSomething < BusinessProcess::Base
  # Specify requirements
  needs :some_method
  needs :some_other_method
  
  # Specify steps  
  steps :do_something,
        :do_something_else
  
  private
  
  def do_something
    @some_result = some_method + 10
  end  
end

class DoSomethingElse < BusinessProcess::Base
  needs :some_other_method
  
  steps :do_something_fancy

  private
  
  def do_something_fancy
    100.times { puts "#{some_other_method} is fancy!" }    
  end
end
```

#### Running specs

```
rspec spec
```
