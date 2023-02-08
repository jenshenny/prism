# frozen_string_literal: true

require "cgi"
require "json"
require "uri"

module YARP
  # YARP additionally ships with a language server conforming to the
  # language server protocol. It can be invoked by running the yarp-lsp
  # bin script (bin/yarp-lsp)
  class LanguageServer
    module Request
      # Represents a hash pattern.
      class Shape
        attr_reader :values

        def initialize(values)
          @values = values
        end

        def ===(other)
          values.all? do |key, value|
            value == :any ? other.key?(key) : value === other[key]
          end
        end
      end

      # Represents an array pattern.
      class Tuple
        attr_reader :values

        def initialize(values)
          @values = values
        end

        def ===(other)
          values.each_with_index.all? { |value, index| value === other[index] }
        end
      end

      def self.[](value)
        case value
        when Array
          Tuple.new(value.map { |child| self[child] })
        when Hash
          Shape.new(value.transform_values { |child| self[child] })
        else
          value
        end
      end
    end

    attr_reader :input, :output

    def initialize(
      input: $stdin,
      output: $stdout
    )
      @input = input.binmode
      @output = output.binmode
    end

    # rubocop:disable Layout/LineLength
    def run
      store =
        Hash.new do |hash, uri|
          filepath = CGI.unescape(URI.parse(uri).path)
          File.exist?(filepath) ? (hash[uri] = File.read(filepath)) : nil
        end

      while (headers = input.gets("\r\n\r\n"))
        source = input.read(headers[/Content-Length: (\d+)/i, 1].to_i)
        request = JSON.parse(source, symbolize_names: true)

        # stree-ignore
        case request
        in { method: "initialize", id: }
          store.clear
          write(id: id, result: { capabilities: capabilities })
        in { method: "initialized" }
          # ignored
        in { method: "shutdown" } # tolerate missing ID to be a good citizen
          store.clear
          write(id: request[:id], result: {})
          return
        in { method: "textDocument/didChange", params: { textDocument: { uri: }, contentChanges: [{ text: }, *] } }
          store[uri] = text
        in { method: "textDocument/didOpen", params: { textDocument: { uri:, text: } } }
          store[uri] = text
        in { method: "textDocument/didClose", params: { textDocument: { uri: } } }
          store.delete(uri)
        in { method: "textDocument/diagnostic", id:, params: { textDocument: { uri: } } }
          uri = request.dig(:params, :textDocument, :uri)
          contents = store[uri]
          write(id: request[:id], result: contents ? diagnostics(contents) : nil)
        in { method: %r{\$/.+} }
          # ignored
        end
      end
    end
    # rubocop:enable Layout/LineLength

    private

    def capabilities
      {
        diagnosticProvider: {
          interFileDependencies: false,
          workspaceDiagnostics: false,
        },
        textDocumentSync: {
          change: 1,
          openClose: true
        }
      }
    end

    def write(value)
      response = value.merge(jsonrpc: "2.0").to_json
      output.print("Content-Length: #{response.bytesize}\r\n\r\n#{response}")
      output.flush
    end

    def diagnostics(source)
      offsets = Hash.new do |hash, key|
        slice = source.byteslice(...key)
        lineno = slice.count("\n") + 1

        char = slice.length
        newline = source.rindex("\n", [char - 1, 0].max) || -1
        hash[key] = { line: lineno, character: char - newline - 1 }
      end

      parse_output = YARP.parse(source)

      {
        kind: "full",
        items: [
          *parse_output.errors.map do |error|
            {
              range: {
                start: offsets[error.location.start_offset],
                end: offsets[error.location.end_offset],
              },
              message: error.message,
              severity: 1,
            }
          end,
          *parse_output.warnings.map do |warning|
            {
              range: {
                start: offsets[warning.location.start_offset],
                end: offsets[warning.location.end_offset],
              },
              message: warning.message,
              severity: 2,
            }
          end,
        ]
      }
    end

    def log(message)
      write(method: "window/logMessage", params: { type: 4, message: message })
    end
  end
end
