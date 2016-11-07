require "spec_helper"

describe Bunny::Channel do
  after :each do
    connection.close if connection.open?
  end

  let(:n) { 200 }

  shared_examples "publish confirms" do
    context "when publishing with confirms enabled" do
      it "increments delivery index" do
        ch = connection.create_channel
        ch.should_not be_using_publisher_confirmations

        ch.confirm_select
        ch.should be_using_publisher_confirmations

        q  = ch.queue("", :exclusive => true)
        x  = ch.default_exchange

        n.times do
          x.publish("xyzzy", :routing_key => q.name)
        end

        ch.next_publish_seq_no.should == n + 1
        ch.wait_for_confirms.should be_true
        sleep 0.25

        q.message_count.should == n
        q.purge

        ch.close
      end

      describe "#wait_for_confirms" do
        it "should not hang when all the publishes are confirmed" do
          ch = connection.create_channel
          ch.should_not be_using_publisher_confirmations

          ch.confirm_select
          ch.should be_using_publisher_confirmations

          q  = ch.queue("", :exclusive => true)
          x  = ch.default_exchange

          n.times do
            x.publish("xyzzy", :routing_key => q.name)
          end

          ch.next_publish_seq_no.should == n + 1
          ch.wait_for_confirms.should be_true

          sleep 0.25

          expect {
            Bunny::Timeout.timeout(2) do
              ch.wait_for_confirms.should be_true
            end
          }.not_to raise_error

        end
      end

      context "when some of the messages get nacked" do
        it "puts the nacks in the nacked_set" do
          ch = connection.create_channel
          ch.should_not be_using_publisher_confirmations

          ch.confirm_select
          ch.should be_using_publisher_confirmations

          q  = ch.queue("", :exclusive => true)
          x  = ch.default_exchange

          n.times do
            x.publish("xyzzy", :routing_key => q.name)
          end

          #be sneaky to simulate a nack
          nacked_tag = nil
          ch.instance_variable_get(:@unconfirmed_set_mutex).synchronize do
            expect(ch.unconfirmed_set).to_not be_empty
            nacked_tag = ch.unconfirmed_set.reduce(ch.next_publish_seq_no - 1) { |lowest, i| i < lowest ? i : lowest }
            ch.handle_ack_or_nack(nacked_tag, false, true)
          end

          ch.nacked_set.should_not be_empty
          ch.nacked_set.should include(nacked_tag)

          ch.next_publish_seq_no.should == n + 1
          ch.wait_for_confirms.should be_false

          ch.nacked_set.should_not be_empty
          ch.nacked_set.should include(nacked_tag)

          sleep 0.25
          q.message_count.should == n
          q.purge

          ch.close
        end
      end
    end
  end

  context "with a multi-threaded connection" do
    let(:connection) do
      c = Bunny.new(:user => "bunny_gem", :password => "bunny_password", :vhost => "bunny_testbed", :continuation_timeout => 10000)
      c.start
      c
    end

    include_examples "publish confirms"
  end

  context "with a single-threaded connection" do
    let(:connection) do
      c = Bunny.new(:user => "bunny_gem", :password => "bunny_password", :vhost => "bunny_testbed", :continuation_timeout => 10000, :threaded => false)
      c.start
      c
    end

    include_examples "publish confirms"
  end
end
