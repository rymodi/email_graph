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

  it 'iterates through each edge and its inverse' do
    expected_yield = [ [g.edge(1, 2), g.edge(2, 1)],
                       [g.edge(2, 3), nil] ]

    expect{ |b| g.with_each_edge_and_inverse(&b) }.to yield_successive_args(*expected_yield)
  end

  describe '#to_undirected' do
    
    it 'returns with the correct edges and vertices using default edge_factory' do
      undirected = g.to_undirected

      expected_edges = [EmailGraph::UndirectedEdge.new(1, 2)]
      expect(undirected.edges).to contain_exactly(*expected_edges)

      expected_vertices = [1, 2]
      expect(undirected.vertices).to contain_exactly(*expected_vertices)
    end

    it 'returns with the correct edges when using a provided edge_factory' do
      at_least_one_way_edge_factory = Proc.new{ |e1, e2| EmailGraph::UndirectedEdge.new(e1.from, e1.to) if e1 }

      undirected = g.to_undirected(&at_least_one_way_edge_factory)

      expected_edges = [ EmailGraph::UndirectedEdge.new(1, 2),
                         EmailGraph::UndirectedEdge.new(2, 3) ]
      expect(undirected.edges).to contain_exactly(*expected_edges)

      expected_vertices = [1, 2, 3]
      expect(undirected.vertices).to contain_exactly(*expected_vertices)
    end

  end

end

describe EmailGraph::DirectedEdge do

  it 'raises when a vertex is nil' do
    expect{ EmailGraph::DirectedEdge.new(nil, 1) }.to raise_exception(ArgumentError)
  end

  it 'converts into a string' do
    edge = EmailGraph::DirectedEdge.new("v", "w")
    expect(edge.to_s).to eq("(v-w)")
  end

end


