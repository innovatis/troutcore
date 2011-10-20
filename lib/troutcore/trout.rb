# I'd like a more specific require here, but /core_ext/string breaks in the current version,
# and /core_ext/string/behavior doesn't monkeypatch itself in. We only need underscore.
require 'active_support/core_ext'

module Troutcore
  class Trout

    def initialize(model_instance)
      @model_instance = model_instance
    end

    module Configuration
      private

      def rails_model(rails_model)
        @rails_model = rails_model
      end

      def sc_attribute(name, &block)
        @sc_attributes ||= {}
        @sc_attributes[name] = Troutcore::Attribute.new(name, &block)
      end

    end
    extend Configuration

    def self.get_rails_model
      @rails_model
    end

    def rails_model
      self.class.get_rails_model
    end

    def to_json
      init = {guid: guid}
      self.class.sc_attributes.inject(init) do |hash, (name, attribute)|
        hash[name] = attribute.apply(@model_instance, self)
        hash
      end
    end

    def self.default_include_attributes
      sc_attributes.values.select(&:always_include?)
    end

    def self.sc_attributes
      @sc_attributes || {}
    end

    def self.find_type(name)
      "#{name.split('.').last}Trout".constantize
    end

    def self.sc_type_name
      name.sub(/Trout$/,'')
    end

    def self.type_from_guid(guid)
      type, _ = guid.split(/-/)
      klass = "#{type.camelize}Trout".constantize
    end

    def self.find_by_guid(guid)
      type, id = guid.split(/-/)
      klass = "#{type.camelize}Trout".constantize
      model_instance = klass.get_rails_model.find(id)
      klass.new(model_instance)
    end

    def guid
      n = self.class.sc_type_name.underscore
      i = @model_instance.id
      "#{n}-#{i}"
    end

  end
end


