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

    def generate_attribute(name)
      self.class.sc_attributes[name].apply(@model_instance, self)
    end

    def to_json
      init = {guid: guid}
      self.class.sc_attributes.inject(init) do |hash, (name, _)|
        hash[name] = generate_attribute(name)
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

    def self.find_all_by_guids(*guids)
      guids.map { |guid| find_by_guid(guid) }
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

    def self.destroy(guid)
      find_by_guid(guid).destroy
    end

    def destroy
      @model_instance.destroy
    end

    def update(data_hash)
      attribute_names = self.class.sc_names_to_rails_names
      filtered = data_hash.inject({}) { |acc, (name, value)|
        if rails_name = attribute_names[name.to_sym]
          acc[rails_name] = value
        end
        acc
      }
      @model_instance.update_attributes(filtered)
    end

    private

    def self.sc_names_to_rails_names
      sc_attributes.inject({}) { |acc, (name, attr)| 
        # TODO We'll eventually also have to do associations here, but that's 
        # more work than needs to be done now...
        if attr.rails_backed? && attr.attribute_type == :rails_attribute
          acc[name.to_sym] = attr.attribute_name
        end
        acc
      }
    end

  end
end


