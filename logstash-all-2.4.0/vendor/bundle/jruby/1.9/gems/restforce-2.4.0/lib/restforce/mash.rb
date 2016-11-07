require 'hashie/mash'

module Restforce
  class Mash < Hashie::Mash
    class << self
      # Pass in an Array or Hash and it will be recursively converted into the
      # appropriate Restforce::Collection, Restforce::SObject and
      # Restforce::Mash objects.
      def build(val, client)
        if val.is_a?(Array)
          val.collect { |a_val| self.build(a_val, client) }
        elsif val.is_a?(Hash)
          self.klass(val).new(val, client)
        else
          val
        end
      end

      # When passed a hash, it will determine what class is appropriate to
      # represent the data.
      def klass(val)
        if val.key? 'records'
          # When the hash has a records key, it should be considered a collection
          # of sobject records.
          Restforce::Collection
        elsif val.key? 'attributes'
          case (val['attributes']['type'])
          when "Attachment"
            Restforce::Attachment
          when "Document"
            Restforce::Document
          else
            # When the hash contains an attributes key, it should be considered an
            # sobject record
            Restforce::SObject
          end
        else
          # Fallback to a standard Restforce::Mash for everything else
          Restforce::Mash
        end
      end
    end

    def initialize(source_hash = nil, client = nil, default = nil, &blk)
      @client = client
      deep_update(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end

    def dup
      self.class.new(self, @client, self.default)
    end

    def convert_value(val, duping = false)
      case val
      when self.class
        val.dup
      when ::Hash
        val = val.dup if duping
        self.class.klass(val).new(val, @client)
      when Array
        val.collect { |e| convert_value(e) }
      else
        val
      end
    end
  end
end
