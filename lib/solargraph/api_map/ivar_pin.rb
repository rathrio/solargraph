module Solargraph
  class ApiMap
    class IvarPin
      attr_reader :node
      attr_reader :namespace
      attr_reader :scope
      attr_reader :docstring

      def initialize api_map, node, namespace, scope, docstring
        @api_map = api_map
        @node = node
        @namespace = namespace
        @scope = scope
        @docstring = docstring
      end

      def name
        node.children[0].to_s
      end

      def suggestion
        @suggestion ||= generate_suggestion
      end

      private

      def generate_suggestion
        type = @api_map.infer_assignment_node_type(node, namespace)
        Suggestion.new(node.children[0], kind: Suggestion::VARIABLE, documentation: docstring, return_type: type)
      end
    end
  end
end