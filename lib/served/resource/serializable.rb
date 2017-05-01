module Served
  module Resource
    module Serializable
      extend ActiveSupport::Concern

      # raised when a handler is defined if the method doesn't exist or if a proc isn't supplied
      class HandlerRequired < StandardError

        def initialize
          super 'a handler is required, it must be a proc or a valid method'
        end

      end

      # pseudo boolean class for serialization
      unless Object.const_defined?(:Boolean)
        class ::Boolean;
        end
      end

      # Specialized class serializers
      SERIALIZERS = {
         Fixnum  => { call: :to_i },
         String  => { call: :to_s },
         Symbol  => { call: :to_sym, converter: -> (value) {
           if value.is_a? Array
             value = value.map { |a| a.to_sym }
             return value
           end
         } },
         Float   => { call: :to_f },
         Boolean => { converter: -> (value) {
           return false unless value == "true"
           true
         } }
      }

      included do
        include Configurable
        include Attributable
        prepend Prepend

        serializer Served.config.serializer # set up the default serializer

        if self == Resource::Base # setup handlers if this is included in the resource class
          class_configurable :handlers do
            {}
          end

          # setup the default handlers, the methods are defined by the configured serializer
          handle((200..201), :serialize_response)
          handle(204) { attributes }

          # 400 level errors
          handle(301) { Resource::MovedPermenantly }
          handle(400) { Resource::BadRequest }
          handle(401) { Resource::Unauthorized }
          handle(403) { Resource::Forbidden }
          handle(404) { Resource::NotFound }
          handle(405) { Resource::MethodNotAllowed }
          handle(406) { Resource::NotAcceptable }
          handle(408) { Resource::RequestTimeout }
          handle(422) { Resource::UnprocessableEntity }

          # 500 level errors
          handle(500) { Resource::InternalServerError }
          handle(503) { Resource::BadGateway }
        end
      end

      class InvalidPresenter < StandardError
      end

      module Prepend

        # extend set attribute to serialize the value using the :serialize option in the attribute options
        def set_attribute(name, value)
          return unless self.class.attributes[name]
          if serializer = self.class.attributes[name][:serialize]
            if serializer.is_a? Proc
              value = serializer.call(value)
            elsif s = SERIALIZERS[serializer]
              called = false
              if s[:call] && value.respond_to?(s[:call])
                value  = value.send(s[:call])
                called = true
              end
              value = s[:converter].call(value) if s[:converter] && !called
            else
              value = serializer.new(value)
            end
          end
          super
        end

      end

      module ClassMethods

        # Sets individual handlers for response codes, accepts a proc or a symbol representing a method
        #
        # @param code [Integer|Range] the response code(s) the handler is to be assigned to
        # @param symbol_or_proc [Symbol|Proc] a symbol representing the method to call, or a proc to be called when
        #   the specific response code has been called. The method or proc should return a hash of attributes, if an
        #   error class is returned it will be raised
        # @yieldreturn [Hash] a hash of attributes, if an error class is returned it will be raised
        def handle(code_or_range, symbol_or_proc=nil, &block)
          @handlers ||= {}
          raise HandlerRequired unless symbol_or_proc || block_given?
          if code_or_range.is_a? Range
            code_or_range.each { |c| @handlers[c] = symbol_or_proc || block }
          else
            @handlers[code_or_range] = symbol_or_proc || block
          end
        end

        # Define a new serializer for the class
        #
        # @param mod [Module] the serializer module to use for this class
        def serializer(mod)
          instance_exec do
            extend mod
          end
        end

        def handle_response(response)
          handler = @handlers[response.code]
          result  = handler.call(response.body) if handler.is_a? Proc
          if result.is_a? HttpError
            raise result.new(self, response)
          end
          send(handler, response.body)
        end

        private

        def serializer_for_attribute(attr, serializer)
          attributes[attr][:serializer] = serializer
        end

      end

      def handle_response(response)
        self.class.handle_response(response)
      end

    end
  end
end