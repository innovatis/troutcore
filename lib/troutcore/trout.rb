# I'd like a more specific require here, but /core_ext/string breaks in the current version,
# and /core_ext/string/behavior doesn't monkeypatch itself in. We only need underscore.
require 'active_support/core_ext'

module Troutcore
  class Trout

    attr_reader :model_instance

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
      attrs = self.class.attributes_for_rails(data_hash)
      @model_instance.update_attributes(attrs)
    end

    def self.create(data_hash)
      attrs = attributes_for_rails(data_hash)
      @rails_model.create(attrs)
    end

    private

    def self.lookup_association(guids)
      if guids.kind_of?(Array)
        guids.map { |guid| find_by_guid(guid).model_instance }
      else
        find_by_guid(guids).model_instance
      end
    end

    def self.attributes_for_rails(data_hash)
      sc_attributes.inject({}) { |acc, (sc_name, attr)|
        if attr.rails_backed?
          rails_name = attr.attribute_name.to_s
          acc[rails_name] = data_hash[sc_name.to_s]
          if acc[rails_name] == "null"
            acc[rails_name] = nil
          end
          if attr.association? && acc[rails_name]
            acc[rails_name] = lookup_association(acc[rails_name])
          end
        end
        acc
      }.reject { |k, v| v.nil? }
    end
  end

end


