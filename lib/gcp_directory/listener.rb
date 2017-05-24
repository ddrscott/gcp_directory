require 'fileutils'

module GcpDirectory
  # Watch for changes and send to API
  class Listener

    def initialize
      @api = Printer.new
    end

    def logger
      GcpDirectory.logger
    end

    def self.logger
      GcpDirectory.logger
    end

    def refresh_token_if_needed
      if @last_refresh.nil? or @last_refresh < 59.minutes.ago
        GcpDirectory.refresh_token
        @last_refresh = Time.now
        @api = Printer.new
      end
    end

    def print(added)
      return if added =~ /\.(done|error|json)$/
      refresh_token_if_needed

      GcpDirectory.config[:printerid] || raise(ArgumentError, '`printerid` not defined in config!')
      options = GcpDirectory.config.merge(
        title: added,
        content: File.read(added)
      )
      logger.info "submitting file: #{added}"
      logger.info @api.submit(**options)
      FileUtils.mv(added, "#{added}.done")
    rescue => error
      logger.error "could not process #{added}", error
      FileUtils.mv(added, "#{added}.error")
    end

    def self.listen
      instance = GcpDirectory::Listener.new
      listener = Listen.to(GcpDirectory.directory) do |modified, added, removed|
        added.each { |file| instance.print(file) } if added
      end
      listener.start # not blocking
      $stderr.puts 'Press <CTRL-C> to stop listening'
      sleep
    end
  end
end
