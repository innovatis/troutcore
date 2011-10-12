module Troutcore
  class Attribute

    def intitialize(name, &block)
      @name = name
      block.bind(self).call
    end

    module Apply
      def apply(model_instance, trout_instance)
        result = send "apply_#{@attribute_type}", model_instance, trout_instance
        # somehow pass the always_include info back up
        # apply transformation
      end

      private

      def apply_rails_attribute(model_instance, _)
        model_instance.send @rails_attribute
      end

      def apply_rails_association(model_instance, _)
        assoc = model_instance.send @rails_association
        if assoc.respond_to?(:each)
          assoc.map(&:troutcore_guid)
        else
          assoc.troutcore_guid
        end
      end

      def apply_derived_attribute(_, trout_instance)
        trout_instance.send(@derived_attribute)
      end

      def apply_derived_association(_, trout_instance)
        trout_instance.send(@derived_association)
      end
    end
    include Apply

    module Configuration
      def rails_attribute(a = @name)
        @rails_attribute = a
        @attribute_type = :rails_attribute
      end

      def rails_association(a = @name)
        @rails_association = a
        @attribute_type = :rails_association
      end

      def derived_attribute(name = @name)
        @derived_attribute = name
        @attribute_type = :derived_attribute
      end

      def always_include
        @always_include = true
      end

      def transformation(a)
        @transformation = a
      end

      def derived_association(name = @name)
        @derived_association = name
        @attribute_type = :derived_association
      end
    end
    include Configuration

  end
end

