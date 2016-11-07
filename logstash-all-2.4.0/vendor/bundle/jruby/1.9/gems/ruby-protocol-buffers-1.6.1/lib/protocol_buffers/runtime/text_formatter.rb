module ProtocolBuffers
  class TextFormatter
    def initialize(options = nil)
      @options = options || {}
    end

    def format(io, message, options = nil)
      message.validate!
      options ||= {}
      options = options.merge(@options)
      options[:nest] ||= 0

      if options[:short]
        indent = ""
        newline = " "
      else
        indent = "  " * options[:nest]
        newline = "\n"
      end

      sep = ""
      message.fields.each do |tag, field|
        next unless message.value_for_tag?(tag)
        value = message.value_for_tag(tag)
        if field.repeated?
          next if value.size == 0
          value.each do |v|
            io.write sep; sep = newline

            format_field(io, field, v, indent, newline, options)
          end
        else
          io.write sep; sep = newline

          format_field(io, field, value, indent, newline, options)
        end
      end

      message.each_unknown_field do |tag_int, value|
        io.write sep; sep = newline

        wire_type = tag_int & 0x7
        id = tag_int >> 3
        format_unknown_field(io, wire_type, id, value, options)
      end

      io.write sep if !options[:short]

      io
    end

    def format_field(io, field, value, indent, newline, options)
      if field.kind_of? Field::GroupField
        name = value.class.name.sub(/\A.*::/, '')
      else
        name = field.name
      end

      io.write "#{indent}#{name}"
      if field.kind_of? Field::AggregateField
        io.write " "
      else
        io.write ": "
      end
      field.text_format(io, value, options)
    end

    def format_unknown_field(io, wire_type, id, value, options)
      options = options.dup
      options[:nest] ||= 0

      if options[:short]
        indent = ""
        newline = " "
      else
        indent = "  " * options[:nest]
        newline = "\n"
      end

      if wire_type == 3
        options[:nest] += 1

        io.write "#{indent}#{id} {#{newline}"
      else
        io.write "#{indent}#{id}: "
      end

      case wire_type
      when 0 # VARINT
        io.write "#{value}"

      when 1 # FIXED64
        lo, hi = value.unpack("V2")
        io.write "0x%016x" % (hi << 32 | lo)

      when 5 # FIXED32
        io.write "0x%08x" % value.unpack("V")

      when 2 # LENGTH_DELIMITED
        value = value.unpack("C*").map { |b| "\\x%02x" % b }.join(nil)
        io.write "\"#{value}\""

      when 3 # START_GROUP
        format(io, value, options)

      when 4 # END_GROUP: never appear
        raise(EncodeError, "Unexpected wire type END_GROUP")
      else
        raise(EncodeError, "unknown wire type: #{wire_type}")
      end
      if wire_type == 3
        io.write "#{indent}}"
      end
    end
  end
end
