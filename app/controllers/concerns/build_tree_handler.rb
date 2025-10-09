# frozen_string_literal: true

module BuildTreeHandler

  def build_tree(nodes)
    nodes.map do |node, children|
      {
        id: node.id,
        name: node.name,
        slug: node.slug,
        children: build_tree(children)
      }
    end
  end
end
