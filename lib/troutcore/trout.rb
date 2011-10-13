module Troutcore
  class Trout

    def rails_model
      self.class.instance_variable_get("@rails_model")
    end

    def self.find_by_scql(scql)
      records = scql.apply_arel(@rails_model)
      records.map { |rec| new(rec) }
    end

    def to_json
      init = {guid: guid}
      self.class.sc_attributes.inject(init) do |hash, (name, attribute)|
        hash[name] = attribute.apply(@model_instance, self)
        hash
      end
    end

    def initialize(model_instance)
      @model_instance = model_instance
    end

    def self.rails_model(rails_model)
      @rails_model = rails_model
    end

    def self.get_rails_model
      @rails_model
    end

    def self.sc_attribute(name, &block)
      @sc_attributes ||= {}
      @sc_attributes[name] = Troutcore::Attribute.new(name, &block)
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

    def self.find_by_guid(guid)
      _, id = guid.split(/-/)
      model_instance = rails_model.find(id)
      new(model_instance)
    end

    def guid
      n = self.class.sc_type_name.underscore
      i = @model_instance.id
      "#{n}-#{i}"
    end

  end
end


