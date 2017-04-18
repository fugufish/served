require 'active_support/core_ext/hash/indifferent_access'
module Served
  module JsonApiError
    class Error
      delegate :[], to: :attrs

      def initialize(attrs = {})
        @attrs = (attrs || {}).with_indifferent_access
      end

      def id
        attrs[:id]
      end

      def status
        attrs[:status]
      end

      def code
        attrs[:code]
      end

      def title
        attrs[:title]
      end

      def detail
        attrs[:detail]
      end

      def source_parameter
        source.fetch(:parameter) do
          source[:pointer] ? source[:pointer].split('/').last : nil
        end
      end

      def source_pointer
        source.fetch(:pointer) do
          source[:parameter] ? "/data/attributes/#{source[:parameter]}" : nil
        end
      end

      def source
        res = attrs.fetch(:source, {})
        res ? res : {}
      end

      def meta
        MetaData.new(attrs.fetch(:meta, {}))
      end

      protected

      attr_reader :attrs
    end
  end
end
