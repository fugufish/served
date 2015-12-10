# Served
[![Build Status](https://travis-ci.org/optoro/served.svg)](https://travis-ci.org/optoro/served)

Served is a gem in the vein of [ActiveResource](https://github.com/rails/activeresource) designed to facilitate
communication between distributed Rails services.

# Installation

Add the following to your Gemfile:

```gem 'served'```


# Usage
A service model can be created by declaring a class inheriting from ```Service::Resource::Base```.

```ruby
class SomeService::SomeResource < Served::Resource::Base

   attribute :name
   attribute :date
   attribute :phone_number, default: '555-555-5555'

end
```

## Saving a resource
Served follows resourceful standards. When a resource is initially saved a **POST** request will be sent
to the service. When the resource already exists, a **PUT** request will be sent. Served determines if
a resource is new or not based on the presence of an id.

# Configuration

Served is configured using ```Served.config```.

## Configuration Options

### Hosts (required)

Served uses the adjacent namespace of the resource to determine the the url for that service. For example given this
configuration:

```ruby
Served.configure do |c|
  c.hosts = {
    some_service:       'http://localhost:3000',
    some_other_service: 'http://localhost:3001'
  }
```

and given this resource

```ruby
class SomeService::SomeResource < Served::Resource::Base

   attribute :name
   attribute :date
   attribute :phone_number

end
```

```SomeService::SomeResource``` would map back to http://localhost:3000/some_resources.

### Timeout

Sets the request time out.