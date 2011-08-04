require 'spec_helper'
require 'micro/network'

describe VCAP::Micro::Network do

  describe "type" do
    it "should accept dhcp type" do
      network = VCAP::Micro::Network.new
      network.type = :dhcp
      network.type.should == :dhcp
    end

    it "should accept static type" do
      network = VCAP::Micro::Network.new
      network.type = :static
      network.type.should == :static
    end
  end

  it "should be able to get the IP of localhost" do
    VCAP::Micro::Network.local_ip("localhost").should == "127.0.0.1"
  end

  it "should be able to ping localhost" do
    VCAP::Micro::Network.ping("localhost").should be_true
  end

  it "should be able to get the IP of the default gateway" do
    VCAP::Micro::Network.gateway.should_not be_nil
  end

  it "should create network config for dhcp" do
    tmp = "tmp/interfaces"
    with_constants "VCAP::Micro::Network::INTERFACES" => tmp do
      network = VCAP::Micro::Network.new
      network.should_receive(:restart).exactly(1).times
      network.dhcp
      File.exist?(tmp).should be_true
    end
  end

  it "should create network config for static" do
    tmp = "tmp/interfaces"
    with_constants "VCAP::Micro::Network::RESOLV_CONF" => tmp do
      state = double('statemachine')
      state.stub(:start)
      state.stub(:started)
      state.stub(:timeout)
      state.stub(:restart)
      state.stub(:state).and_return(:starting)
      Statemachine.stub(:build).and_return(state)
      network = VCAP::Micro::Network.new
      network
      network.should_receive(:restart).exactly(1).times
      conf = {
        "address" => "1.2.3.4",
        "netmask" => "255.255.255.0",
        "network" => "1.2.3.0",
        "broadcast" => "1.2.3.255",
        "dns" => "8.8.8.8"
      }
      network.static(conf)
      File.exist?(tmp).should be_true
    end
  end

end