module EmailGraph

  class UndirectedGraph
    
    def initialize
      @store = {}
    end

    # All vertices
    def vertices
      @store.keys
    end

    # All edges
    def edges
      @store.values.to_set.flatten
    end
     
    # A specific edge from +v+ to +w+
    def edge(v, w)
      (@store[v] || []).find{ |e| e.vertices.include?(w) }
    end

    # Edges involving a vertex +v+
    def edges_with(v)
      @store[v]
    end

    # Adds a vertex if it doesn't already exist and returns it
    def add_vertex(v)
      @store[v] ||= Set.new
    end

    # Adds an edge and associated vertices if they don't already
    # exist and returns the edge
    def add_edge(e)
      e.vertices.each do |v| 
        add_vertex(v)
        @store[v].add(e)
      end
    end

  end

  class UndirectedEdge
    attr_reader :vertices
    
    def initialize(v, w)
      raise ArgumentError, "Vertices cannot be falsy" unless v && w
      @vertices = Set.new([v, w])
    end
    
    def hash
      @vertices.hash
    end

    def ==(other)
      @vertices == other.vertices
    end
    alias eql? ==

    def to_s
      a = @vertices.to_a
      "(#{a[0]}-#{a[1]})"
    end

  end

end
