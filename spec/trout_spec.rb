require './lib/troutcore/trout'

class Troutcore::Attribute
end

describe Troutcore::Trout do
  let(:temperature_attribute) { stub(attribute_type: :derived_attribute, rails_backed?: false) }
  let(:side_attribute) { stub(attribute_name: :side, attribute_type: :rails_attribute, rails_backed?: true) }
  let(:rails_model) { stub }
  let(:bacon_klass) { Class.new(Troutcore::Trout) }
  let(:bacon) { bacon_klass.new(rails_model) }

  before(:each) {
    @klass = (Class.new(Troutcore::Trout) {})
    @klass.stub!(:name => "DummyTrout")
  }

  describe "configuration" do

    it "can set the rails_model" do
      @klass.instance_eval do
        rails_model String
      end
      @klass.get_rails_model.should == String
    end

    it "can create an attribute" do
      Troutcore::Attribute.should_receive(:new).with(:attribute)
      @klass.instance_eval do
        sc_attribute(:attribute)
      end
      @klass.sc_attributes.should_not be_empty
    end

    it "returns an empty hash if asked for its attributes but none are present" do
      @klass.sc_attributes.should == {}
    end

  end

  it "generates an attribute" do
    @klass.stub(sc_attributes: {key: stub(apply: "value")})
    @klass.new(stub).generate_attribute(:key).should == "value"
  end

  it "generates a guid based on the rails model's id" do
    object = stub(id: 42)
    @klass.new(object).guid.should == "dummy-42"
  end

  it "infers its type name in SC" do
    @klass.sc_type_name.should == "Dummy"
  end

  it "can be looked up by type" do
    # have to fake this out since we're not actually assigning the constant.
    Object.should_receive(:const_missing).with("DummyTrout").and_return(@klass)
    Troutcore::Trout.find_type("Dummy").should == @klass
  end

  it "knows which of its associations should always be included in result sets" do
    a1, a2, a3, a4 = [false, true, true, false].map { |b| stub(always_include?: b)}
    @klass.stub!(sc_attributes: {a1: a1, a2: a2, a3: a3, a4: a4})
    @klass.default_include_attributes.should == [a2, a3]
  end

  it "can look up a subclass from a guid" do
    Object.should_receive(:const_missing).with("DummyTrout").and_return(@klass)
    Troutcore::Trout.type_from_guid("dummy-42").should == @klass
  end

  it "can look up a specific instance of a type from a guid" do
    Object.should_receive(:const_missing).with("DummyTrout").and_return(@klass)
    rails_instance, trout_instance = stub, stub
    @klass.stub(get_rails_model: stub(find: rails_instance))
    @klass.should_receive(:new).with(rails_instance).and_return(trout_instance)
    Troutcore::Trout.find_by_guid("dummy-42").should == trout_instance
  end

  it "can look up many records by guid" do
    trout1, trout2 = stub, stub
    Troutcore::Trout.should_receive(:find_by_guid).with("dummy-42").and_return(trout1)
    Troutcore::Trout.should_receive(:find_by_guid).with("dummy-41").and_return(trout2)
    Troutcore::Trout.find_all_by_guids("dummy-42", "dummy-41").should == [trout1, trout2]
  end

  it "can destroy a record" do
    rails_model.stub(destroy: true)
    Troutcore::Trout.should_receive(:find_by_guid).with("bacon-42").and_return(bacon)
    Troutcore::Trout.destroy('bacon-42').should be_true
  end

  it "can update a record" do
    # side is a rails_Attribute, temperature is derived
    bacon_klass.stub(sc_attributes: {side: side_attribute, temperature: temperature_attribute})
    # so we only update the rails model with side.
    rails_model.should_receive(:update_attributes).with(side: 'eggs').and_return(true)
    bacon.update({side: 'eggs', temperature: 1000000}).should be_true
  end

  xit "can create a record" do
  end

  xit "converts an instance to json for sproutcore" do
  end

end
