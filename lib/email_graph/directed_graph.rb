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

    # Get specific edge from +v+ to +w+
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
      @from_store[e.from].add(e)
      @to_store[e.to].add(e)
      e
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
