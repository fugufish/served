# Served
[![Build Status](https://travis-ci.org/fugufish/served.svg)](https://travis-ci.org/fugufish/served)

Served is a gem in the vein of [ActiveResource](https://github.com/rails/activeresource) designed to facilitate
communication between distributed Rails services.

# Installation

Add the following to your Gemfile:

```gem 'served'```

# Usage

```ruby
class SomeService::SomeResource < Served::Resource::Base

   attribute :name
   attribute :date
   attribute :phone_number

end
```

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