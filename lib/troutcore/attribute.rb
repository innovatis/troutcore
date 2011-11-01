module Troutcore
  class Attribute

    attr_reader :name
    def initialize(name, &block)
      @name = name
      instance_eval(&block)
    end

    module Apply
      def apply(model_instance, trout_instance)
        result = send "apply_#{@attribute_type}", model_instance, trout_instance
        # somehow pass the always_include info back up
        # apply transformation
      end

      private

      def apply_rails_attribute(model_instance, _)
        model_instance.send @attribute_name
      end

      def apply_rails_association(model_instance, _)
        assoc = model_instance.send @attribute_name
        if assoc.respond_to?(:each)
          assoc.compact.map(&:troutcore_guid)
        else
          assoc.try :troutcore_guid
        end
      end

      def apply_derived_attribute(model_instance, trout_instance)
        trout_instance.send(@attribute_name, model_instance)
      end

      def apply_derived_association(model_instance, trout_instance)
        trout_instance.send(@attribute_name, model_instance)
      end
    end
    include Apply

    def association?
      [:derived_association, :rails_association].include?(@attribute_type)
    end

    def rails_backed?
      [:rails_attribute, :rails_association].include?(@attribute_type)
    end

    def always_include?
      !!@always_include
    end

    def get_transformation
      @transformation
    end

    attr_reader :attribute_name, :attribute_type

    module Configuration

      [:rails_attribute, :rails_association,
        :derived_attribute, :derived_association].each do |name|
        define_method(name) do |a = @name|
          @attribute_name = a
          @attribute_type = name
        end
      end

      def always_include
        @always_include = true
      end

      def transformation(a)
        @transformation = a
      end

    end
    include Configuration

  end
end

