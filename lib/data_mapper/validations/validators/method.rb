# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      class Method < Validator

        attr_reader :method

        def initialize(attribute_name, options={})
          super
          @method = @options.fetch(:method, @attribute_name)
        end

        def call(resource)
          result, error_message = resource.__send__(method)
          add_error(resource, error_message, attribute_name) unless result
          result
        end

        def ==(other)
          method == other.method && super
        end

      end # class Method

    end # module Validators
  end # module Validations
end # module DataMapper
