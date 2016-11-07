# encoding: utf-8
require 'logstash/codecs/base'
require 'logstash/namespace'

# The "sflow" codec is for decoding sflow v5 flows.
class LogStash::Codecs::Sflow < LogStash::Codecs::Base
  config_name 'sflow'

  # Specify which Sflow versions you will accept.
  config :versions, :validate => :array, :default => [5]

  # Specify which sflow fields must not be send in the event
  config :optional_removed_field, :validate => :array, :default => %w(sflow_version header_size
 ip_header_length ip_dscp ip_ecn ip_total_length ip_identification ip_flags ip_fragment_offset ip_ttl ip_checksum
 ip_options tcp_seq_number tcp_ack_number tcp_header_length tcp_reserved tcp_is_nonce tcp_is_cwr tcp_is_ecn_echo
 tcp_is_urgent tcp_is_ack tcp_is_push tcp_is_reset tcp_is_syn tcp_is_fin tcp_window_size tcp_checksum
 tcp_urgent_pointer tcp_options vlan_cfi sequence_number flow_sequence_number vlan_type udp_length udp_checksum)

  # Specify if codec must perform SNMP call so agent_ip for interface resolution.
  config :snmp_interface, :validate => :boolean, :default => false

  # Specify if codec must perform SNMP call so agent_ip for interface resolution.
  config :snmp_community, :validate => :string, :default => 'public'

  # Specify the max number of element in the interface resolution local cache (only if snmp_interface true)
  config :interface_cache_size, :validate => :number, :default => 1000

  # Specify the duration for each element in the interface resolution local cache (only if snmp_interface true)
  config :interface_cache_ttl, :validate => :number, :default => 3600

  def initialize(params = {})
    super(params)
    @threadsafe = false
  end

  # def initialize

  def assign_key_value(event, bindata_kv)
    unless bindata_kv.nil? or bindata_kv.to_s.eql? ''
      bindata_kv.each_pair do |k, v|
        if v.is_a?(BinData::Choice)
          assign_key_value(event, bindata_kv[k])
        else
          unless @removed_field.include? k.to_s or v.is_a?(BinData::Array)
            event["#{k.to_s}"] = v.to_s
          end
        end
      end
    end
  end

  # @param [Object] event
  # @param [Object] decoded
  # @param [Object] sample
  # @param [Object] record
  def common_sflow(event, decoded, sample)
    event['agent_ip'] = decoded['agent_ip'].to_s
    assign_key_value(event, decoded)
    assign_key_value(event, sample)
  end

  def snmp_call(event)
    if @snmp_interface
      if event.include?('source_id_type') and event['source_id_type'].to_s == '0'
        if event.include?('source_id_index')
          event["source_id_index_descr"] = @snmp.get_interface(event["agent_ip"], event["source_id_index"])
        end
        if event.include?('input_interface')
          event["input_interface_descr"] = @snmp.get_interface(event["agent_ip"], event["input_interface"])
        end
        if event.include?('output_interface')
          event["output_interface_descr"] = @snmp.get_interface(event["agent_ip"], event["output_interface"])
        end
        if event.include?('interface_index')
          event["interface_index_descr"] = @snmp.get_interface(event["agent_ip"], event["interface_index"])
        end
      end
    end
  end

  public
  def register
    require 'logstash/codecs/sflow/datagram'
    require 'logstash/codecs/snmp/interface_resolver'

    # noinspection RubyResolve
    @removed_field = %w(record_length record_count record_entreprise record_format sample_entreprise sample_format
 sample_length sample_count sample_header data storage) | @optional_removed_field

    if @snmp_interface
      @snmp = SNMPInterfaceResolver.new(@snmp_community, @interface_cache_size, @interface_cache_ttl, @logger)
    end
  end

  # def register

  public
  def decode(payload)
    header = SFlowHeader.read(payload)
    unless @versions.include?(header.sflow_version)
      @logger.warn("Ignoring Sflow version v#{header.sflow_version}")
      return
    end

    decoded = SFlow.read(payload)

    events = []

    decoded['samples'].each do |sample|
      @logger.debug("sample: #{sample}")
      #Treat case with no flow decoded (Unknown flow)
      if sample['sample_data'].to_s.eql? ''
        @logger.warn("Unknown sample entreprise #{sample['sample_entreprise'].to_s} - format #{sample['sample_format'].to_s}")
        next
      end

      #treat sample flow and expanded sample flow
      if sample['sample_entreprise'] == 0 && (sample['sample_format'] == 1 || sample['sample_format'] == 3)
        # Create the logstash event
        event = LogStash::Event.new({})

        common_sflow(event, decoded, sample)

        sample['sample_data']['records'].each do |record|
          # Ensure that some data exist for the record
          if record['record_data'].to_s.eql? ''
            @logger.warn("Unknown record entreprise #{record['record_entreprise'].to_s}, format #{record['record_format'].to_s}")
            next
          end

          assign_key_value(event, record)

        end
        #compute frame_length_times_sampling_rate
        if event.include?('frame_length') and event.include?('sampling_rate')
          event["frame_length_times_sampling_rate"] = event['frame_length'].to_i * event['sampling_rate'].to_i
        end

        if sample['sample_format'] == 1
          event["sflow_type"] = 'flow_sample'
        else
          event["sflow_type"] = 'expanded_flow_sample'
        end

        #Get interface dfescr if snmp_interface true
        snmp_call(event)

        events.push(event)

      #treat counter flow and expanded counter flow
      elsif sample['sample_entreprise'] == 0 && (sample['sample_format'] == 2 || sample['sample_format'] == 4)
        sample['sample_data']['records'].each do |record|
          # Ensure that some data exist for the record
          if record['record_data'].to_s.eql? ''
            @logger.warn("Unknown record entreprise #{record['record_entreprise'].to_s}, format #{record['record_format'].to_s}")
            next
          end

          # Create the logstash event
          event = LogStash::Event.new({})
          common_sflow(event, decoded, sample)

          assign_key_value(event, record)

          if sample['sample_format'] == 2
            event["sflow_type"] = 'counter_sample'
          else
            event["sflow_type"] = 'expanded_counter_sample'
          end


          #Get interface dfescr if snmp_interface true
          snmp_call(event)

          events.push(event)
        end
      end
    end

    events.each do |event|
      yield event
    end
  end # def decode
end # class LogStash::Filters::Sflow
