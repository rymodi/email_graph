require 'spec_helper'
require 'ostruct'

describe EmailGraph::InteractionGraph do
  let(:a0) { OpenStruct.new(name: "a0", email: "a0@example.com") }
  let(:a1) { OpenStruct.new(name: "a1", email: "a1@example.com") }
  let(:msg) { OpenStruct.new(from: [a0], to: [a1], date: Time.now) }
  let(:g) { EmailGraph::InteractionGraph.new }

  describe '#add_message' do

    it 'adds vertices (identities)' do 
      g.add_message(msg)

      expect(g.vertices).to contain_exactly(a0.email, a1.email)
    end

    it 'adds edges (relationships)' do
      g.add_message(msg)

      expected_edge = EmailGraph::InteractionRelationship.new(a0.email, a1.email)
      expect(g.edges).to contain_exactly(expected_edge)
    end

    it 'adds interactions to relationships' do
      g.add_message(msg)

      expect(g.edge(a0.email, a1.email).interactions).to contain_exactly(msg.date)
    end

    it 'adds interactions ignoring duplicates' do
      msg_with_dups = OpenStruct.new( from: [a0],
                                      to:   [a1],
                                      cc:   [a1], 
                                      date: Time.now )

      g.add_message(msg_with_dups)

      expect(g.edge(a0.email, a1.email).interactions).to contain_exactly(msg_with_dups.date)
    end

    it 'raises when message addresses have nil emails' do
      nil_email = OpenStruct.new(name: "Nil Email", email: nil)
    
      msg_with_nil_email = OpenStruct.new( from: [a0],
                                           to:   [nil_email],
                                           date: Time.now )

      expect{g.add_message(msg_with_nil_email)}.to raise_exception(ArgumentError)
    end

    it 'normalizes emails if no processor is provided' do
      a_norm = OpenStruct.new(name: "Norm", email: "test@gmail.com")
      a_not_norm = OpenStruct.new(name: "Not Norm", email: "tEs.t+blah@gmail.com")

      msg = OpenStruct.new(from: [a_norm], to: [a_not_norm], date: Time.now)
      g.add_message(msg)

      expected_edge = EmailGraph::InteractionRelationship.new('test@gmail.com', 'test@gmail.com')
      expect(g.edges).to contain_exactly(expected_edge)
    end

    it 'processes emails if a processor is provided' do
      processor = Proc.new{ |e| "EMAIL@EMAIL.COM" }
      g.add_message(msg, email_processor: processor)  

      expect(g.vertices).to contain_exactly("EMAIL@EMAIL.COM")
    end

  end

  describe '#to_mutual_graph' do
    
    it 'returns with the correct edges and vertices using default filter' do
      g.add_message(msg)
      g.add_message(OpenStruct.new(from: [a1], to: [a0], date: Time.now))
      mutual_graph = g.to_mutual_graph

      expected_edges = [EmailGraph::MutualRelationship.new(a0.email, a1.email)]
      expect(mutual_graph.edges).to contain_exactly(*expected_edges)

      expected_vertices = [a0.email, a1.email]
      expect(mutual_graph.vertices).to contain_exactly(*expected_vertices)

      expect(mutual_graph.edge(a0.email, a1.email).interactions.size).to eq(2)
    end

  end

end
