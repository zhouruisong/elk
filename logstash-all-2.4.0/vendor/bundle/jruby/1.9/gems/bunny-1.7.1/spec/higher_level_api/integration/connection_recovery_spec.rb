require "spec_helper"
require "rabbitmq/http/client"

unless ENV["CI"]
  describe "Connection recovery" do
    let(:connection)  {  }
    let(:http_client) { RabbitMQ::HTTP::Client.new("http://127.0.0.1:15672") }

    def close_all_connections!
      http_client.list_connections.each do |conn_info|
        begin
          http_client.close_connection(conn_info.name)
        rescue Bunny::ConnectionForced
          # This is not a problem, but the specs intermittently believe it is.
        end
      end
    end

    def wait_for_recovery
      sleep 1.5
    end

    def with_open(c = Bunny.new(:network_recovery_interval => 0.2, :recover_from_connection_close => true), &block)
      begin
        c.start
        block.call(c)
      ensure
        c.close
      end
    end

    def with_open_multi_host( c = Bunny.new( :hosts => ["127.0.0.1", "localhost"],
                                             :network_recovery_interval => 0.2,
                                             :recover_from_connection_close => true), &block)
      begin
        c.start
        block.call(c)
      ensure
        c.close
      end
    end

    def with_open_multi_broken_host( c = Bunny.new( :hosts => ["broken", "127.0.0.1", "localhost"],
                                             :hosts_shuffle_strategy => Proc.new { |hosts| hosts }, # We do not shuffle for these tests so we always hit the broken host
                                             :network_recovery_interval => 0.2,
                                             :recover_from_connection_close => true), &block)
      begin
        c.start
        block.call(c)
      ensure
        c.close
      end
    end

    def ensure_queue_recovery(ch, q)
      q.purge
      x = ch.default_exchange
      x.publish("msg", :routing_key => q.name)
      sleep 0.5
      q.message_count.should == 1
      q.purge
    end

    def ensure_queue_binding_recovery(x, q, routing_key = "")
      q.purge
      x.publish("msg", :routing_key => routing_key)
      sleep 0.5
      q.message_count.should == 1
      q.purge
    end

    def ensure_exchange_binding_recovery(ch, source, destination, routing_key = "")
      q  = ch.queue("", :exclusive => true)
      q.bind(destination, :routing_key => routing_key)

      source.publish("msg", :routing_key => routing_key)
      q.message_count.should == 1
      q.delete
    end

    #
    # Examples
    #

    it "reconnects after grace period" do
      with_open do |c|
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        c.should be_open
      end
    end

    it "reconnects after grace period (with multiple hosts)" do
      with_open_multi_host do |c|
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        c.should be_open
      end
    end

    it "reconnects after grace period (with multiple hosts, including a broken one)" do
      with_open_multi_broken_host do |c|
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        c.should be_open
      end
    end

    it "recovers channels" do
      with_open do |c|
        ch1 = c.create_channel
        ch2 = c.create_channel
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch1.should be_open
        ch2.should be_open
      end
    end

    it "recovers channels (with multiple hosts)" do
      with_open_multi_host do |c|
        ch1 = c.create_channel
        ch2 = c.create_channel
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch1.should be_open
        ch2.should be_open
      end
    end

    it "recovers channels (with multiple hosts, including a broken one)" do
      with_open_multi_broken_host do |c|
        ch1 = c.create_channel
        ch2 = c.create_channel
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch1.should be_open
        ch2.should be_open
      end
    end

    it "recovers basic.qos prefetch setting" do
      with_open do |c|
        ch = c.create_channel
        ch.prefetch(11)
        ch.prefetch_count.should == 11
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open
        ch.prefetch_count.should == 11
      end
    end


    it "recovers publisher confirms setting" do
      with_open do |c|
        ch = c.create_channel
        ch.confirm_select
        ch.should be_using_publisher_confirms
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open
        ch.should be_using_publisher_confirms
      end
    end

    it "recovers transactionality setting" do
      with_open do |c|
        ch = c.create_channel
        ch.tx_select
        ch.should be_using_tx
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open
        ch.should be_using_tx
      end
    end

    it "recovers client-named queues" do
      with_open do |c|
        ch = c.create_channel
        q  = ch.queue("bunny.tests.recovery.client-named#{rand}")
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open
        ensure_queue_recovery(ch, q)
        q.delete
      end
    end


    it "recovers server-named queues" do
      with_open do |c|
        ch = c.create_channel
        q  = ch.queue("", :exclusive => true)
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open
        ensure_queue_recovery(ch, q)
      end
    end

    it "recovers queue bindings" do
      with_open do |c|
        ch = c.create_channel
        x  = ch.fanout("amq.fanout")
        q  = ch.queue("", :exclusive => true)
        q.bind(x)
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open
        ensure_queue_binding_recovery(x, q)
      end
    end

    it "recovers exchange bindings" do
      with_open do |c|
        ch = c.create_channel
        x  = ch.fanout("amq.fanout")
        x2 = ch.fanout("bunny.tests.recovery.fanout")
        x2.bind(x)
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open
        ensure_exchange_binding_recovery(ch, x, x2)
      end
    end

    it "recovers allocated channel ids" do
      with_open do |c|
        q = "queue#{Time.now.to_i}"
        10.times { c.create_channel }
        c.queue_exists?(q).should be_false
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        c.queue_exists?(q).should be_false
        # make sure the connection isn't closed shortly after
        # due to "second 'channel.open' seen". MK.
        c.should be_open
        sleep 0.1
        c.should be_open
        sleep 0.1
        c.should be_open
      end
    end

    it "recovers consumers" do
      with_open do |c|
        delivered = false

        ch = c.create_channel
        q  = ch.queue("", :exclusive => true)
        q.subscribe do |_, _, _|
          delivered = true
        end
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open

        q.publish("")
        sleep 0.5
        expect(delivered).to be_true
      end
    end

    it "recovers all consumers" do
      n = 1024

      with_open do |c|
        ch = c.create_channel
        q  = ch.queue("", :exclusive => true)
        n.times do
          q.subscribe do |_, _, _|
            delivered = true
          end
        end
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open

        q.consumer_count.should == n
      end
    end

    it "recovers all queues" do
      n = 256

      qs = []

      with_open do |c|
        ch = c.create_channel

        n.times do
          qs << ch.queue("", :exclusive => true)
        end
        close_all_connections!
        sleep 0.1
        c.should_not be_open

        wait_for_recovery
        ch.should be_open

        qs.each do |q|
          ch.queue_declare(q.name, :passive => true)
        end
      end
    end
  end
end
