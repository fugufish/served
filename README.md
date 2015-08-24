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