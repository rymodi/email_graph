require 'time'
require 'net/imap'
require 'gmail_xoauth'

module GmailFetcher

  class Fetcher
    attr_accessor :batch_size, :email, :access_token

    def initialize(email: nil, access_token: nil)
      @email = email
      @access_token = access_token
      @batch_size = 500
    end

    def count_messages(mailboxes: ['INBOX'])
      mailboxes.inject(0){ |r, m| r + imap.status(m, ['MESSAGES'])['MESSAGES'] }
    end

    def each_message(mailboxes: ['INBOX'], batch_size: nil)
      each_envelope(mailboxes: mailboxes, batch_size: batch_size) do |e|
        m = Message.from_net_imap_envelope(e)
        yield m if block_given?
      end
    end

    def each_envelope(mailboxes: ['INBOX'], batch_size: nil)
      mailboxes.each do |mailbox|
        # Needed before fetching
        imap.examine(mailbox)

        batch_size ||= @batch_size
        limit = count_messages(mailboxes: [mailbox])

        (1..limit).each_slice(batch_size) do |range|
          envelope_batch = imap.fetch(range, 'ENVELOPE') || []
          envelope_batch.each{ |e| yield e if block_given? }
        end
      end
    end

    def imap_connect
      Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false).tap do |imap|
        imap.authenticate('XOAUTH2', email, access_token)
      end
    end

    def imap
      @imap ||= imap_connect
    end
    
  end

  Message = Struct.new(:from, :to, :cc, :bcc, :date) do

    def initialize(**kwargs)
      kwargs.each{ |k, v| self[k] = v }
    end
    
    # @param e [+Net::IMAP::Envelope+]
    # @return [Message]
    def self.from_net_imap_envelope(e)
      addresses_by_field = {}
      address_fields = [:from, :to, :cc, :bcc]
      address_fields.each do |field|
        addresses = e.attr['ENVELOPE'].send(field) || []
        addresses_by_field[field] = addresses.map{ |a| Address.from_net_imap_address(a) }
      end
      
      date_raw = e.attr['ENVELOPE'].date
      date = nil
      begin
        date = Time.parse(date_raw) if date_raw
      rescue ArgumentError
        # Observed cases:
        # - date_raw == "{DATE}"
        # - Time.parse raises 'ArgumentError: argument out of range'
      end

      new(**addresses_by_field, date: date)
    end
  end

  Address = Struct.new(:name, :email) do

    def initialize(**kwargs)
      kwargs.each{ |k, v| self[k] = v }
    end

    # @param a [Net::IMAP::Address]
    # @return [Address]
    def self.from_net_imap_address(a)
      new( name:  a.name, 
           email: "#{a.mailbox}@#{a.host}" )
    end

  end

end
