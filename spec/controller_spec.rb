require 'active_support/core_ext/array'
require './lib/troutcore/controller'

class Troutcore::SCQLQuery
end

class Troutcore::Trout
end

describe Troutcore::Controller do
  
  before do 
    @controller = stub.extend(Troutcore::Controller)
  end

  it "can #fetch" do
    params = { data: {
      recordType: 'Scheduler.Label',
      conditions: '' } }
     hash = {"RecordType1" => [stub(to_json: "I'm a data hash.")]}
    Troutcore::SCQLQuery.stub(:new).
      with(params[:data]).
      and_return(stub(execute: hash))
    @controller.stub(params: params)
    @controller.stub(:render).
      with(json: {"RecordType1" => ["I'm a data hash."]}).
      and_return(true)

    @controller.fetch.should be_true
  end

  it "can #retrieveRecords" do
    Troutcore::Trout.stub(:find_by_guid).
      with("bacon-1").
      and_return(stub(to_json: "BACON", class: stub(sc_type_name: "Bacon")))
    Troutcore::Trout.stub(:find_by_guid).
      with("eggs-1").
      and_return(stub(to_json: "EGGS",  class: stub(sc_type_name: "Eggs")))

    params = {data: ["bacon-1", "eggs-1"]}
    @controller.stub(params: params)

    @controller.stub(:render).
      with(json: {"Bacon" => ["BACON"], "Eggs" => ["EGGS"]}).
      and_return(true)

    @controller.retrieveRecords.should be_true
  end

  describe "#commitRecords" do

    xit "can create records" do
      params = {
        data: {
          create: [{guid: "bacon-1", side: "eggs"}],
        }
      }
      bacon_trout = stub
      Troutcore::Trout.stub(type_from_guid).
        with("bacon-1")
        and_return(bacon_trout)
    end

    it "can update records" do
      params = {
        data: {
          update: {'0' => {guid: 'bacon-1', side: 'bananas'}}
        }
      }
      bacon_trout = stub
      bacon_trout.should_receive(:update).with(side: 'bananas')
      Troutcore::Trout.stub(:find_by_guid).
        with("bacon-1").
        and_return(bacon_trout)
      @controller.stub(params: params)
      @controller.should_receive(:render).with(text: "OK")
      @controller.commitRecords
    end

    it "can destroy records" do
      params = {
        data: {
          destroy: ["bacon-1"]
        }
      }
      @controller.stub(params: params)
      Troutcore::Trout.should_receive(:destroy).with('bacon-1').and_return(true)
      @controller.should_receive(:render).with(text: "OK")
      @controller.commitRecords
    end

  end

end
