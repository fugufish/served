# Served
[![Build Status](https://travis-ci.org/optoro/served.svg?branch=master)](https://travis-ci.org/optoro/served)
[![Gem Version](https://badge.fury.io/rb/served.svg)](https://badge.fury.io/rb/served)

Served is a gem in the vein of [ActiveResource](https://github.com/rails/activeresource) designed to facilitate
communication between distributed services and APIs.

# Installation

Add the following to your Gemfile:

```gem 'served'```

Served supports Ruby versions `>= 2.1` and versions of Rails `>= 3.2`, including Rails 5.
# Configuration
Served is configured by passing a block to ```Served::configure```.

```ruby
Served.configure do |config|
  config.hosts = {
    'some_service' => 'http://localhost:3000'
   }
   
   config.timeout = 100
   
   config.backend = :patron
   config.serializer = Served::Serializers::Json
end
```

## Hosts
Served models derive their hostname by mapping their parent module to the `Served::hosts` configuration hash. For
example, `SomeService::SomeResource` would look up its host configuration at 
`Served.config.hosts['some_service']`.

The host configuration accepts an (Addressable)[https://github.com/sporkmonger/addressable] template mapping
`resource` as the resource name (derived from the model name) and `query` as the params. For example:

```
http://localhost:3000/{resource}{?query*}
```

For more on building Addressable templates view the addressable documentation. If the host configuration is not an
Addressable template, a default template will be applied (```{resource}.json{?query*}```). This is the current
maintained for backwards compatibility, however the extension will likely be removed for the 0.2 release.

## Timeout
Sets the request timeout in milliseconds.

## Backend
Configure the HTTP client backend. Supports either :http (default), which will use the HTTP client, or :patron, which 
will use Patron. Patron is suggested for use if high concurrency between requests is required. Also requires the 
machine to have libcurl.

# Defining a Resource
A service model can be created by declaring a class inheriting from ```Service::Resource::Base```.

```ruby
class SomeService::SomeResource < Served::Resource::Base
   attribute :name
   attribute :date
   attribute :phone_number

end
```

## Resource Configuration
The default configuration can be changed for individual resources. The currently available resource configuration
options are:

* **host** - the service host the request is sent to
* **headers** - the headers that are sent with the request
* **timeout** - the timeout for the individual resource
* **resource_name** - the resource_name of the resource, as applicable to the Addressable template

## Serialization

Attributes can be serialized as Ruby objects when the `serialize:` option is passed to `#attribute`. This can be any
primitive object (`Fixnum`, `String`, `Symbol`, etc.) or any object whose initializer accepts a single `Hash` or `Array`
as an argument and responds to `to_json`. This also means that Served resources can be used as nested objects as well, 
which can allow for strict request validation (as explained in the next section).

When `#save` is called on a resource, non primitive objects will be serialized for transport using their `to_json`
method, this also means that attributes can be valid `ActiveRecord` objects. Served provides a generic validatable
non-resource class called `Served::Attribute::Base` that can be used to define deep nested object mapping for 
complex json data strucutres. 

Example:

```ruby
class SomeService::SomeThing < Served::Attribute::Base
  attribute :id
end

class SomeService::SomeResource < Served::Resource::Base
  attribute :thing, serialize: SomeService::SometThing
end
```

## JsonAPI 

Served does support JSON API responses and comes with a dedicated serializer. Nested resources are supported as well. 
By default `Served` is raising exceptions on error.

```ruby
class JsonApiResource < Served::Resource::Base
  def self.serializer
    Served::Serializers::JsonApi
  end

  def self.raise_on_exceptions
    false
  end
end

class PeopleResource < JsonApiResource
  attribute :name
  resource_name 'friends'
end

class ServiceResource < JsonApiResource
  attribute :id
  attribute :first_name, presence: true
  attribute :friends, serialize: PeopleResource, default: []

  resource_name 'service_resource'
end
```


## Validations
`Served::Resource::Base` includes `AciveModel::Validations` and supports all validation methods with the exception of 
`Uniquness`. As a shotcut validations can be passed to the `#attribute` method much in the same way as it can be passed 
to the `#validate` method. 

Example:

```ruby
class SomeService::SomeResource < Served::Resource::Base
  attribute :name, presence: true, format: {with: /[a-z]+/}, length: { within: (3..10) }
  attribute :date
  
  validates_each :date do |record, attr, value|
    # ...
   end
end

```

When a serializer is added to an attribute if that serializer responds to `#valid?` it will be validated along with the
 rest of the request. These nested validations will bubble up to errors added to the top level  attribute.


```ruby
class SomeService::SomeThing < Served::Attribute::Base
  attribute :id, presence: true
end

class SomeService::SomeResource < Served::Resource::Base
  attribute :thing, presence: true, serialize: SomeService::SometThing
end
```

This allows scenarios where a data structure needs to be enforced and to f fail fast when the structure is invalid.
is particularly useful when developing internal API libraries that communicate between internal services using a uniform data model.

## Saving a resource

Served follows resourceful standards. When a resource is initially saved a **POST** request will be sent
to the service. When the resource already exists, a **PUT** request will be sent. Served determines if
a resource is new or not based on the presence of an id.

### Service Errors

If the service returns an error, by default an error is thrown. If you want it to behave more like AR where you get 
validation errors and a `save` returns `true` or `false`, you can configure that.
 

```ruby
class JsonApiResource < Served::Resource::Base
  def self.raise_on_exceptions
    false
  end
end
``` 
