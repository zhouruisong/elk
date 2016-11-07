# -*- coding: UTF-8 -*-

require 'strscan'
require 'racc/parser'

module ProtocolBuffers; end

class ProtocolBuffers::TextScanner
  def initialize(text)
    @text = text.encode(Encoding::UTF_8)
    @scanner = StringScanner.new(@text)
    @lineno = 1
  end

  attr_reader :lineno

  def scan
    while @scanner.rest?
      case
      when @scanner.skip(/[ \t\v]+/)
        next
      when @scanner.skip(/#.*?$/)
        next
      when @scanner.skip(/\r?\n|\r/)
        @lineno += 1
        next
      when @scanner.scan(/[.:<>{}\[\]]/)
        c = @scanner[0]
        yield [c, c]
      when @scanner.scan(/true/)
        yield [:bool, true]
      when @scanner.scan(/false/)
        yield [:bool, false]
      when @scanner.scan(/["']/)
        quote = @scanner[0]
        line = lineno
        if @scanner.scan(/(.*?)(?<!\\)#{quote}/)
          str = @scanner[1]
          yield [:string, unescape(str)]
        else
          raise Racc::ParseError, "unterminated string from line #{line}"
        end
      when @scanner.scan(/([+-])?[0-9]+\.[0-9]+([Ee][+-]?[0-9]+)?/)
        yield [:float, Float(@scanner[0])]
      when @scanner.scan(/([+-])?0[Bb]([01]+)/)
        yield [:integer, Integer(@scanner[0], 2)]
      when @scanner.scan(/([+-])?0[Xx]([[:xdigit:]]+)/)
        yield [:integer, Integer(@scanner[0], 16)]
      when @scanner.scan(/([+-])?0[Oo]?([0-7]+)/)
        yield [:integer, Integer(@scanner[0], 8)]
      when @scanner.scan(/([+-])?(?:0[Dd])?([0-9]+)/)
        yield [:integer, Integer(@scanner[0], 10)]
      when @scanner.scan(/[[:alpha:]_][[:alnum:]_]*/)
        yield [:identifier, @scanner[0]]
      else
        line = lineno
        raise Racc::ParseError, "unexpected character at: line #{line}: #{@scanner.rest.inspect}"
      end
    end
    yield [false, nil]
  end

  private
  ESCAPE_SEQUENCE = {
    'a' => "\a",
    'b' => "\b",
    'f' => "\f",
    'n' => "\n",
    'r' => "\r",
    't' => "\t",
    'v' => "\v",
    '\\' => "\\",
    '"' => '"',
    "'" => "'",
  }.freeze

  def unescape(str)
    str.gsub(%r!
      \\ (?:
        [Xx]([[:xdigit:]]{1,2}) |
        ([0-7]{1,3})            |
        ([abfnrtv\\'"])
    )!x) do
      case
      when $1
        Integer($1, 16).chr
      when $2
        Integer($2, 8).chr
      when $3
        ESCAPE_SEQUENCE[$3]
      end
    end
  end
end
