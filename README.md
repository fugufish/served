# Served
[![Build Status](https://travis-ci.org/optoro/served.svg)](https://travis-ci.org/optoro/served)
[![Gem Version](https://badge.fury.io/rb/served.svg)](https://badge.fury.io/rb/served)

Served is a gem in the vein of [ActiveResource](https://github.com/rails/activeresource) designed to facilitate
communication between distributed services and APIs.

# Installation

Add the following to your Gemfile:

```gem 'served'```

# Configuration
Served is configured by passing a block to ```Served::configure```.

```ruby
Served.configure do |config|
  config.hosts = {
    'some_service' => 'http://localhost:3000'
   }
   
   config.timeout = 100
   
   config.backend = :patron
end
```

## Hosts
Served models derive their hostname by mapping their parent module to the ```Served::hosts``` configuration hash. For
example, ```SomeService::SomeResource``` would look up its host configuration at 
```Served.config.hosts['some_service']```.

The host configuration accepts an (Addressable)[https://github.com/sporkmonger/addressable] template mapping
```resource``` as the resource name (derived from the model name) and ```query``` as the params. For example:

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


