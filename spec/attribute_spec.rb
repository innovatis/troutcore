require './lib/troutcore/attribute'

describe Troutcore::Attribute do

  describe "configuration" do

    it "sets up a rails-backed attribute" do
      attr = (Troutcore::Attribute.new(:dummy) {
        rails_attribute :attr_name
        transformation :some_transformation
      })

      attr.attribute_type.should == :rails_attribute
      attr.attribute_name.should == :attr_name
      attr.get_transformation.should == :some_transformation
    end

    it "sets up a derived association" do
      attr = (Troutcore::Attribute.new(:dummy) {
        derived_association :attr_name
        always_include
      })

      attr.always_include?.should be_true
      attr.attribute_type.should == :derived_association
      attr.attribute_name.should == :attr_name
    end

  end

  describe "#apply" do

    let(:model_instance) { stub(:dummy) }
    let(:trout_instance) { stub() }

    it "delegates rails_attributes to the rails model instance" do
      attr = (Troutcore::Attribute.new(:dummy) { rails_attribute })
      model_instance.should_receive(:dummy).and_return("some value")
      attr.apply(model_instance, trout_instance).should == "some value"
    end

    it "delegates derived_attributes to the Troutcore::Trout object" do
      attr = (Troutcore::Attribute.new(:dummy) { derived_attribute })
      trout_instance.should_receive(:dummy).and_return("some value")
      attr.apply(model_instance, trout_instance).should == "some value"
    end

    it "delegates rails_associations to the rails model instance" do
      rec1, rec2, rec3 = [1,2,3].map { |n| stub(troutcore_guid: "record-#{n}") }
      attr = (Troutcore::Attribute.new(:dummy) { rails_association })
      model_instance.should_receive(:dummy).and_return([rec1, rec2, rec3])
      attr.apply(model_instance, trout_instance).should == ["record-1", "record-2", "record-3"]
    end

    it "delegates derived_associations to the Troutcore::Trout object" do
      attr = (Troutcore::Attribute.new(:dummy) { derived_association })
      trout_instance.should_receive(:dummy).and_return([1,2,3])
      attr.apply(model_instance, trout_instance).should == [1,2,3]
    end

  end


end
