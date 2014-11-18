require 'spec_helper'

describe EmailGraph::DirectedGraph do
  let(:edge_pairs) {[ [1, 2],
                      [2, 1],
                      [2, 3] ]}
  let(:edges) { edge_pairs.map{ |p| EmailGraph::DirectedEdge.new(p[0], p[1]) } }
  let(:g) do
    EmailGraph::DirectedGraph.new.tap do |g| 
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

  it 'returns a specific edge' do
    expect(g.edge(1,2)).to eq(EmailGraph::DirectedEdge.new(1,2))
  end

  it 'returns edges from a vertex' do
    expect(g.edges_from(2).map(&:to)).to contain_exactly(1, 3)
  end

  it 'returns edges to a vertex' do
    expect(g.edges_to(2).map(&:from)).to contain_exactly(1)
  end

end

describe EmailGraph::DirectedEdge do

  it 'raises when a vertex is nil' do
    expect{ EmailGraph::DirectedEdge.new(nil, 1) }.to raise_exception(ArgumentError)
  end

end

