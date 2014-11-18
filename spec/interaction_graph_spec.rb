require 'spec_helper'
require 'ostruct'

describe EmailGraph::InteractionGraph do

  describe '#add_message' do

    let(:a0) { OpenStruct.new(name: "a0", email: "a0@example.com") }
    let(:a1) { OpenStruct.new(name: "a1", email: "a1@example.com") }
    let(:msg) { OpenStruct.new(from: [a0], to: [a1], date: Time.now) }
    let(:g) { EmailGraph::InteractionGraph.new }

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

  end
end
