require 'spec_helper'

describe EmailGraph::UndirectedGraph do
  let(:edge_pairs) {[ [1, 2],
                      [2, 3] ]}
  let(:edges) { edge_pairs.map{ |p| EmailGraph::UndirectedEdge.new(p[0], p[1]) } }
  let(:g) do
    EmailGraph::UndirectedGraph.new.tap do |g|
      edges.each{ |e| g.add_edge(e) }
      g.add_vertex(4)
    end
  end 

  it 'returns all vertices' do
    expect(g.vertices).to contain_exactly(1, 2, 3, 4)
  end

  it 'returns all edges' do
    expect(g.edges).to contain_exactly(*edges)
  end

  it 'returns a specific edge, vertex order ignored' do
    expected_edge = EmailGraph::UndirectedEdge.new(1,2)
    expect(g.edge(2, 1)).to eq(expected_edge)
  end

  it 'returns edges involving a vertex' do
    expected_edges = [EmailGraph::UndirectedEdge.new(2,3)]
    expect(g.edges_with(3)).to contain_exactly(*expected_edges)
  end

  it 'returns an existing edge if available when adding one' do
    e = NewUndirectedEdgeType.new(2, 3)

    expect(g.add_edge(e)).to be_instance_of(EmailGraph::UndirectedEdge)
  end

end

describe EmailGraph::UndirectedEdge do

  it 'raises when a vertex is nil' do
      expect{ EmailGraph::UndirectedEdge.new(nil, 1) }.to raise_exception(ArgumentError)
  end

  it 'converts into a string' do
    edge = EmailGraph::UndirectedEdge.new("v", "w")
    expect(edge.to_s).to match(/^\((v-w|w-v)\)$/)
  end

end

class NewUndirectedEdgeType < EmailGraph::UndirectedEdge; end
