module EmailGraph
  
  # Directed graph of identities and their relationships, created by parsing
  # messages.
  class InteractionGraph < DirectedGraph

    # @param messages [Array<#from, #to, #cc, #bcc, #date>] optional 
    #   message-like objects. See {#add_message} for specification.
    def initialize(messages: [])
      super()
      messages.each{ |m| add_message(m) }
    end

    # Adds a message to the graph.
    #
    # @param m [#from, #to, #cc, #bcc, #date] message-like object. Field methods
    #   should return an array of objects that respond to #name and #email;
    #   #date should return an instance of +Time+.
    # @return m param
    def add_message(m)
      # Fields are in prioritized order (e.g., if in 'to', don't process again in 'cc')
      to_emails = []
      [:to, :cc, :bcc].each do |field|
        addresses = m.send(field) || []
        addresses.each do |a|
          unless to_emails.include?(a.email)
            from ||= m.from.first.email
            to = a.email
             
            add_interaction(from, to, m.date)
             
            to_emails << to
          end
        end
      end

      m
    end

  private

    def add_interaction(from, to, date)
      r = add_edge(InteractionRelationship.new(from, to))
      r.add_interaction(date)
    end

  end

  class InteractionRelationship < DirectedEdge
    attr_reader :interactions

    def initialize(from, to)
      super
      @interactions = []
    end

    def add_interaction(date)
      interactions << date
    end
  end

end
