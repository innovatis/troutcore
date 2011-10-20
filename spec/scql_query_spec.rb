require 'set'
require './lib/troutcore/scql_query'

class Troutcore::Trout
end

describe Troutcore::SCQLQuery do
  let(:trout_class) { stub(default_include_attributes: []) }
  let(:customer1) { stub(class: stub(sc_type_name: "Assoc")) }
  let(:customer2) { stub(class: stub(sc_type_name: "Assoc")) }
  let(:trout2) { stub(class: stub(sc_type_name: "Initial")) }
  let(:trout1) { stub(class: stub(sc_type_name: "Initial")) }

  let(:query) {
    Troutcore::SCQLQuery.new({
      recordType: "Dummy",
      conditions: "(date >= {startDate}) AND (date <= {endDate})",
      parameters: {
        startDate: 1,
        endDate: 2
      }
    }).tap do |q|
      q.stub(trout: trout_class)
    end
  }

  it "takes a query" do
   query.record_type.should == "Dummy"
  end

  it "fetches a query with no default includes" do
    query.stub(hardcoded_date_query: [trout1, trout2])
    query.execute.should == {
      "Initial" => [trout1, trout2]
    }
  end

  it "fetches a query with one level of inclusion" do
    trout_class.stub(default_include_attributes: [stub(name: "customer")])
    trout1.stub(generate_attribute: ["customer-1"])
    trout2.stub(generate_attribute: ["customer-2"])
    query.stub(hardcoded_date_query: [trout1, trout2])

    Troutcore::Trout.should_receive(:find_all_by_guids).
      with("customer-1","customer-2").
      and_return([customer1, customer2])

    query.execute.should == {
      "Initial" => [trout1, trout2],
      "Assoc"   => [customer1, customer2]
    }
  end

  xit "fetches a query with two levels of inclusion"
  xit "fetches a query with an arbitrary level of inclusion"
  xit "does not explode when fetching a query that has a circular dependency"

  describe "hardcoded queries" do

    xit "can look up a specific date query"

    # this is pretty lackluster.
    it "can look up all items where workspace = true" do
      trout_class.stub(get_rails_model: stub(where: [:one]))
      trout_class.should_receive(:new).with(:one).and_return(trout1)
      query.instance_variable_set("@conditions", "workspace = true")
      query.execute.should == {"Initial" => [trout1]}
    end

    it "can look up all items of a certain type" do
      trout_class.stub(get_rails_model: stub(all: [:one]))
      trout_class.should_receive(:new).with(:one).and_return(trout1)
      query.instance_variable_set("@conditions", "")
      query.execute.should == {"Initial" => [trout1]}
    end

  end

end
