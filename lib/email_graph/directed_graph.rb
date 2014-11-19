module EmailGraph

  # Graph with single, directed edges between vertices; loops allowed.
  #
  # Has these additional specifications:
  # - Vertices and edges are hashable objects; the latter should 
  #   inherit from Edge
  # - Efficient fetching of in-edges in addition to out
  class DirectedGraph

    def initialize
      @from_store = {}
      @to_store   = {}
    end

    # All vertices
    def vertices
      @from_store.keys
    end

    # All edges
    def edges
      @from_store.values.to_set.flatten
    end

    # A specific edge from +v+ to +w+
    def edge(v, w)
      (@from_store[v] || []).find{ |e| e.to == w }
    end

    # Out-edges from vertex +v+ 
    def edges_from(v)
      @from_store[v]
    end

    # In-edges to vertex +v+
    def edges_to(v)
      @to_store[v]
    end

    # Adds a vertex if it doesn't already exist and returns it
    def add_vertex(v)
      @from_store[v] ||= Set.new
      @to_store[v]   ||= Set.new
    end

    # Adds an edge and associated vertices if they don't already
    # exist and returns the edge
    def add_edge(e)
      add_vertex(e.from); add_vertex(e.to)
      (@from_store[e.from].add?(e) && @to_store[e.to].add(e) && e) || edge(e.from, e.to)
    end
    
    # Yields each edge and its inverse to the provided block.
    #
    # Option to provide edges; default is all edges.
    # 
    # A pair set is yielded only once (not again in reverse).
    def with_each_edge_and_inverse(edges=nil, &block)
      edges ||= self.edges

      yielded_pairs = Set.new
      edges.each do |e|
        pair = Set.new([e.from, e.to])
        if !yielded_pairs.include?(pair)
          e_inverse = edge(e.to, e.from)
          block.call(e, e_inverse)
          yielded_pairs << pair
        end
      end
    end

    # Converts to an instance of EmailGraph::Undirected graph.
    #
    # The optional +edge_factory+ block should take a pair of an edge and its
    # inverse (if it exists), and return either an undirected edge-ish or if there
    # should be no edge between the two vertices, then return nil. If
    # no block is passed, an +UndirectedEdge+ will be created if both the edge and
    # its inverse exist.
    #
    # Only adds vertices that have edges, i.e., no isolated vertices in result.
    def to_undirected(&edge_factory)
      edge_factory ||= Proc.new{ |e1, e2| UndirectedEdge.new(e1.from, e1.to) if e1 && e2 }      

      edges = Set.new
      with_each_edge_and_inverse do |e, e_inverse|
        new_edge = edge_factory.call(e, e_inverse)
        edges.add(new_edge) if new_edge
      end

      UndirectedGraph.new.tap do |g|
        edges.each{ |e| g.add_edge(e) } 
      end
    end
 
  end

  class DirectedEdge
    attr_reader :from
    attr_reader :to

    def initialize(from, to)
      raise ArgumentError, "Vertices cannot be falsy" unless from && to
      @from = from
      @to = to
    end

    def hash
      from.hash ^ to.hash
    end

    def ==(other)
      from == other.from && to == other.to
    end
    alias eql? ==

    def to_s
      "(#{from}-#{to})"
    end
  end
    
end
