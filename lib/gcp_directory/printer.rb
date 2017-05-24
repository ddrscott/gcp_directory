module GcpDirectory
  # Maps to https://developers.google.com/cloud-print/docs/appInterfaces
  class Printer
    include HTTParty
    base_uri 'https://www.google.com/cloudprint'

    def initialize(auth = GcpDirectory.auth_client(GcpDirectory.token_path))
      auth.access_token || raise(ArgumentError, "`access_token` not set in #{auth}")
      @auth = auth
    end

    def jobs(**options)
      self.class.post('/jobs', with_default_options(options))
    end

    def submit(printerid:, title:, ticket: default_ticket)
      self.class.post('/submit', with_default_options(body: {
        printerid: printerid,
        title: title,
        ticket: ticket.to_json
      }))
    end

    def default_ticket
      {
        version: '1.0',
        print: {}
      }
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