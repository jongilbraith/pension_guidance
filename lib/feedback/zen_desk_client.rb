require 'zendesk_api'

module Feedback
  class ZenDeskClient
    def initialize(ticket_class: ZendeskAPI::Ticket, client: nil)
      @ticket_class = ticket_class
      @client = client
    end

    def create_ticket(message)
      ticket_class.create!(
        client,
        subject: 'Online Booking feedback',
        comment: { value: message },
        submitter_id: ENV['ZENDESK_API_SUBMITTER_ID'],
        tags: %w(online_booking)
      )
    end

    private

    attr_reader :ticket_class

    def client
      @client ||= ZendeskAPI::Client.new do |config|
        config.url      = ENV['ZENDESK_API_URI']
        config.username = ENV['ZENDESK_API_USERNAME']
        config.token    = ENV['ZENDESK_API_TOKEN']
      end
    end
  end
end
