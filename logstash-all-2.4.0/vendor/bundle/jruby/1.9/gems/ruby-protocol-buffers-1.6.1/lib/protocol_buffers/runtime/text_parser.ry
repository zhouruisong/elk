# vim: set ft=racc fenc=us-ascii : -*- mode: racc coding: US-ASCII -*-
class ProtocolBuffers::TextParser
token identifier string integer bool float
rule
  message    : /* none */
               {
                 result = current_message
               }
             | message field

  field      : field_name ':' primitive_value
               {
                 set_field(val[0], val[2])
               }
             | field_name ':' identifier
               {
                 field, enum_symbol = val[0], val[2]
                 unless field.kind_of?(ProtocolBuffers::Field::EnumField)
                   raise Racc::ParseError, "not a enum field: %s" % field.name
                 end
                 value = field.value_from_name(enum_symbol)
                 unless value
                   raise Racc::ParseError, "enum type %s has no value named %s" % [field.name, enum_symbol]
                 end
                 set_field(field, value)
               }
             | message_field_head '<'
               {
                 field = _values[-2]
                 push_message(field.proxy_class.new)
               }
               message '>'
               {
                 pop_message
                 set_field(val[0], val[3])
               }
             | message_field_head '{'
               {
                 field = _values[-2]
                 push_message(field.proxy_class.new)
               }
               message '}'
               {
                 pop_message
                 set_field(val[0], val[3])
               }

  message_field_head : field_name
                     | field_name ':'

  field_name : identifier
               {
                 field = current_message.class.field_for_name(val[0])
                 if field
                   return field
                 end

                 # fallback for case mismatch in group fields.
                 field = current_message.fields.find { |tag,field| field.name.to_s.downcase == val[0].downcase }
                 field &&= field.last
                 if field && field.kind_of?(ProtocolBuffers::Field::GroupField)
                   return field
                 end

                 raise Racc::ParseError, "no such field %s in %s" % [val[0], current_message.class]
               }
             | '[' qualified_name ']'
               {
                 raise NotImplementedError, "extension is not yet supported"
               }

  qualified_name   : identifier
                     {
                       result = [val[0]]
                     }
                   | qualified_name '.' identifier
                     {
                       result = (val[0] << val[2])
                     }

  primitive_value : concat_string
                  | integer
                  | float
                  | bool
  concat_string   : string
                  | concat_string string
                    {
                      result = val[0] + val[1]
                    }
end

---- header
require 'protocol_buffers/runtime/text_scanner'

---- inner
def initialize
  @msgstack = []
end

attr_accessor :yydebug

def parse_text(text, message)
  scanner = ProtocolBuffers::TextScanner.new(text)
  parse_from_scanner(scanner.enum_for(:scan), message)
end

def parse_from_scanner(scanner, message)
  @msgstack.clear
  push_message(message)
  yyparse(scanner, :each)
  pop_message
end

private :yyparse, :do_parse
private
def current_message
  @msgstack.last
end

def push_message(message)
  @msgstack.push(message)
end

def pop_message
  @msgstack.pop
end

def set_field(field, value)
  msg = current_message
  if field.repeated?
    msg.value_for_tag(field.tag) << value
  else
    msg.set_value_for_tag(field.tag, value)
  end
  msg
end
