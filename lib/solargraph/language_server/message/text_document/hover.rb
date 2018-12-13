require 'uri'
require 'htmlentities'

# inline audrey experiments
require 'http'
require 'oj'

module Solargraph::LanguageServer::Message::TextDocument
  class Hover < Base
    def process
      filename = uri_to_file(params['textDocument']['uri'])
      line = params['position']['line']
      col = params['position']['character']
      contents = []
      suggestions = host.definitions_at(filename, line, col)
      last_link = nil
      suggestions.each do |pin|
        parts = []
        this_link = pin.link_documentation
        if !this_link.nil? and this_link != last_link
          parts.push this_link
        end
        parts.push HTMLEntities.new.encode(pin.detail) unless pin.kind == Solargraph::Pin::NAMESPACE or pin.detail.nil?
        parts.push pin.documentation unless pin.documentation.nil? or pin.documentation.empty?
        contents.push parts.join("\n\n") unless parts.empty?
        last_link = this_link unless this_link.nil?

        if pin.is_a?(Solargraph::Pin::Method)
          root_node_id = pin.path
          root_node_id = "Object#{root_node_id}" if root_node_id.start_with? '#'

          contents.push("### Examples parameters")
          pin.parameters.each do |param|
            sample = HTTP.get(
              'http://localhost:9292/samples',
              params: {
                identifier: param,
                category: 'ARGUMENT',
                root_node_id: root_node_id,
                source: filename
              }
            ).parse.sample
            contents.push("#{param}: #{sample['value']}") if sample
          end
        end
      end

      set_result(
        contents: {
          kind: 'markdown',
          value: contents.join("\n\n")
        }
      )
    end
  end
end
