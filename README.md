# EmailGraph

Build and analyze relationship graph data from email history.

Focus is on identities and interactions between them, for example:
  * Who are my strong contacts, as identified by some two-way interaction
    threshold function?
  * Which of my contacts can we infer are also strong contacts with one another?
  * What is the distribution of my email interactions with a given person over
    time?

## Graph types

There are two types of graphs to be built from email data.

### 1. Interaction graph

Class: `EmailGraph::InteractionGraph`

This is a directed graph where each vertex is an email address and each edge is
an instance of `EmailGraph::InteractionRelationship` - a directed interaction
history between two emails.

The graph has these properties:
  * Implements common graph methods (e.g., `#vertices`, `#edges`, etc)
  * Efficient fetching of vertices' in-edges (not always a default of graph
    structures)
  * Loops allowed

Given a message, an interaction is created from the sender to every address in
the `to`, `cc`, and `bcc` fields - there is no distinction among the latter.

`EmailGraph::InteractionRelationship` objects have an `interactions` attribute,
which holds an array of the `Time` objects of the interactions.

Example:

```ruby
# Assuming you have an array 'messages' of message-like objects (see below for
# how to use the Gmail fetcher)
g = EmailGraph::InteractionGraph.new
messages.each{ |m| g.add_message(m) }

# ...or...

g = EmailGraph::InteractionGraph.new(messages: messages)

# For example, see a sorted list of your email contacts by emails sent
g.edges_from("your@emailhere.com")
  .sort_by{ |e| -e.interactions.size }
  .map{ |e| [e.to, e.interactions.size] }
```

### 2. Mutual relationship graph

Class: `EmailGraph::UndirectedGraph` (just uses the abstract class)

This is an undirected graph where each vertex is also an email, however, this
time, the edges are instances of `EmailGraph::MutualRelationship` - an
undirected edge that similarly includes an interaction history (though an
undirected one).

This graph is created from an `EmailGraph::InteractionGraph` by creating
undirected edges from pairs of directed edge inverses. Optionally, a filter can
be applied during this process to determine whether an undirected edge is
created for a given pair of directed edges.

```ruby
g = EmailGraph::InteractionGraph.new(messages: messages)

# This creates the graph using the default filter, which is that an edge has to
# have an inverse in order to create a new undirected edge.
mg = g.to_mutual_graph

# Alternatively, you can specify a custom filter. For example, this replicates
# the one used by A. Chapanond et al. in their analysis of emails* from the Enron
# case data set
filter = Proc.new do |e, e_inverse|
  if e && e_inverse
    counts = [e.interactions.size, e_inverse.interactions.size]
    counts.all?{ |c| c >= 6 } && counts.inject(:+) >= 30
  else
    false
  end
end
mg = g.to_mutual_graph(&filter)
```

\*Chapanond, Anurat, Mukkai S. Krishnamoorthy, and Bülent Yener. "Graph theoretic
and spectral analysis of Enron email data." Computational & Mathematical
Organization Theory 11.3 (2005): 265-281.

## Email normalization

You'll likely want to normalize email addresses before adding them to a graph.
Otherwise, you'll end up with separate vertices for different capitalizations of
the same address - not to mention differences with '.' placement and other
issues.

`EmailGraph::InteractionGraph` will do this by default using SoundCloud's
[Normailize](https://github.com/soundcloud/normailize) gem.

You can also pass your own email processing block on instantiation for the
entire graph, or when calling `#add_message`.

## Fetching emails

A fetcher for Gmail is included for convenience.

```ruby
g = EmailGraph::InteractionGraph.new

email = "XXX"
# You'll need an OAuth2 access token with Gmail permissions. One way to get one
# is to use the Google Oauth Playground (https://developers.google.com/oauthplayground/)
# and under "Gmail API v1" authorize "https://mail.google.com/".
access_token = "XXX"

f = EmailGraph::GmailFetcher::Fetcher.new( email: email,
                                           access_token: access_token )

# This should cover all emails from that account. If no mailbox param is
# provided, defaults to Inbox.
mailboxes = ['[Gmail]/All Mail', '[Gmail]/Trash']
f.each_message(mailboxes: mailboxes){ |m| g.add_message(m) }
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'email_graph'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install email_graph
