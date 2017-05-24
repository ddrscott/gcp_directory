module GcpDirectory
  # Maps to https://developers.google.com/cloud-print/docs/appInterfaces
  class Printer
    include HTTParty
    base_uri 'https://www.google.com/cloudprint'

    debug_output(GcpDirectory.logger)

    def initialize(auth = GcpDirectory.token_client)
      auth.access_token || raise(ArgumentError, "`access_token` not set in #{auth}")
      @auth = auth
    end

    def jobs(**options)
      self.class.post('/jobs', with_default_options(options))
    end

    def submit(printerid:, title:, content:, ticket:)
      self.class.post('/submit', with_default_options(body: {
        printerid: printerid,
        title: title,
        ticket: ticket.to_json,
        content: content
      }))
    end

    def with_default_options(**options)
      {
        headers: {
          'Authorization' => "OAuth #{@auth.access_token}"
        }
      }.merge(options)
    end
  end
end
