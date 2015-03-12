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

##### Real usages

###### Service for sending Pubnub notifications

```ruby
class SendPubnubNotification < BusinessProcess::Base
  needs :auth_key
  needs :channel
  needs :notification

  def call
    PubnubWrapper::Client.publish(
        channel: "#{channel}_#{auth_key}",
        auth_key: auth_key,
        message: {
            link: notification.message,
            title: notification.title,
            remove_notification_path: notification.decorate.update_path,
            status: notification.status_property,
        },
        http_sync: true,
    )
  end
end

# Usage:
SendPubnubNotification.call(auth_key: 'user', channel: 'candidate', notification: 'Hi candidate!')
```

###### Service for sending Pubnub notifications

```ruby
class CreateExportNotification < BusinessProcess::Base
  needs :export
  needs :owner

  def call
    Notification.create(notification_attributes).tap do |notification|
      notification.update_attribute(:message, notification.link_to_download)
    end
  end

  private

  def notification_attributes
    {
        title: I18n.t('export_notification.name', name: export.exportable.to_s),
        owner_id: owner.id,
        owner_type: owner.class.base_class.name,
        expire_at: Time.now + 5.minutes,
        properties: {
            dom_id: export.dom_id,
            export_path: export.save_path,
            status: export.status,
        },
    }
  end
end

# Usage:
CreateExportNotification.call(export: export, owner: owner)
```

#### Running specs

```
rspec spec
```
