require "spec_helper"

describe Bunny::Queue, "#pop" do
  let(:connection) do
    c = Bunny.new(:user => "bunny_gem", :password => "bunny_password", :vhost => "bunny_testbed",
                  :automatically_recover => false)
    c.start
    c
  end

  after :each do
    connection.close if connection.open?
  end

  context "with all defaults" do
    it "fetches a messages which is automatically acknowledged" do
      ch = connection.create_channel

      q  = ch.queue("", :exclusive => true)
      x  = ch.default_exchange

      msg = "xyzzy"
      x.publish(msg, :routing_key => q.name)

      sleep(0.5)
      get_ok, properties, content = q.pop
      expect(get_ok).to be_kind_of(Bunny::GetResponse)
      expect(properties).to be_kind_of(Bunny::MessageProperties)
      expect(properties.content_type).to eq("application/octet-stream")
      expect(get_ok.routing_key).to eq(q.name)
      expect(get_ok.delivery_tag).to be_kind_of(Bunny::VersionedDeliveryTag)
      expect(content).to eq(msg)
      q.message_count.should == 0

      ch.close
    end
  end


  context "with an empty queue" do
    it "returns an empty response" do
      ch = connection.create_channel

      q  = ch.queue("", :exclusive => true)
      q.purge

      get_empty, properties, content = q.pop
      expect(get_empty).to eq(nil)
      expect(properties).to eq(nil)
      expect(content).to eq(nil)
      q.message_count.should == 0

      ch.close
    end
  end
end
