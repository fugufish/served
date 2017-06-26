# Changelog

## 0.3.3
* fixes regression where #presenter is not respected

## 0.3.2
* fixes edge case where TrueClass is passed in intead of a string to a `Boolean` serialized attribute

## 0.3.1
* fixes regression in error handling

## 0.3.0
* Added Serializers feature, ability to define different methods of serializing resource response
* New error handling, will report different errors based on response from resource
* added `handler` response configuration, allows different handlers to be set up for specific
  response codes.
* added `Json` handler as default
* added `JsonApi` handler

## 0.2.2
* Resource::Base#destroy added, (backend functionality existed, but was never added to #resource)

## 0.2.1
* Backtrace handler no longer explodes when the resource doesn't present a well formatted backtrace

## 0.2.0

* new HTTP client backend functionality, ability to support multiple
  HTTP backends
* `headers` updated to merge, can be called multiple times, allows modularization
* backend support for `HTTParty`, `HTTP`, and `Patron`
* `host_config` method removed from `Support::Resource::Base`
* update travis to test against  Ruby 2.4.0, Ruby 2.1.9, Ruby 2.3.2
* various refactoring
* add `validation_on_save` option to allow skipping validation on save
* better configuration inheritance in resources
* if using HTTParty as a backend `Errno::ECONNREFUSED` will no longer be returned for connection errors, 
`Served::HTTPClient::ConnectionFailed` will be raised instead

## 0.1.12
 * add validation support
 * add serialization support
 * allow definition of individual attributes
 * add resource level `headers` option
 * add resource level `reasource_name` option
 * add resource level `host` option, `host_config` will be deprecated in 0.2.0
 * add `Served::Attribute::Base` class
 
## 0.1.11
 * add resource level `reasource_name` option
 * add resource level `host` option

## 0.1.10
* make `timeout` configurable per resource

## 0.1.8

* fix buggy GET request template expansion defaults