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

