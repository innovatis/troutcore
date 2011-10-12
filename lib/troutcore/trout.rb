module Troutcore
  class Trout

    def rails_model
      self.class.instance_variable_get("@rails_model")
    end

    def self.find_by_scql(scql)
      records = scql.apply(rails_model)
      records.map { |rec| new(rec) }
    end

    def to_json
      self.class.sc_attributes.inject({}) do |hash, (name, attribute)|
        hash[name] = attribute.apply(@model_instance)
        hash
      end
    end

    def initialize(model_instance)
      @model_instance = model_instance
    end

    def self.rails_model(rails_model)
      @rails_model = rails_model
    end

    def self.sc_attribute(name, &block)
      @sc_attributes ||= {}
      @sc_attributes[name] = Troutcore::Attribute.new(name, &block)
    end

    def self.sc_attributes
      @sc_attributes
    end

    def self.inherited(klass)
      @subclasses ||= {}
      @subclasses << klass
    end

    def self.find_type(name)
      @subclasses.find { |klass| klass.sc_type_name == name}
    end

    def self.sc_type_name
      name.sub(/Trout$/,'')
    end

    def self.find_by_guid(guid)
      _, id = guid.split(/-/)
      model_instance = rails_model.find(id)
      new(model_instance)
    end

  end
end


