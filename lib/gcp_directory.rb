# external libs
require 'active_support/all'
require 'google/api_client/client_secrets'
require 'json'
require 'httparty'
require 'semantic_logger'
require 'yaml'
require 'listen'

SemanticLogger.default_level = :trace
SemanticLogger.add_appender(file_name: 'listener.log', formatter: :color)

# Listen for changes in a directory and send to Google Cloud Print
module GcpDirectory

  CALLBACK_URL = 'http://localhost:8000/callback'.freeze

  def self.logger
    SemanticLogger['Listener']
  end

  def self.directory=(dir)
    @directory = dir
  end

  def self.directory
    @directory ||= File.expand_path('.')
  end

  def self.config
    JSON.parse(File.read(File.join(directory, 'printer.json'))).symbolize_keys
  end

  def self.secrets_path
    File.join(directory, '.secrets.json')
  end

  def self.token_path
    File.join(directory, '.token.json')
  end

  def self.token_client
    auth_client(token_path)
  end

  def self.auth_client(path)
    # check secrets exist
    File.file?(path) || raise("#{path} does not exist! Please download from https://console.developers.google.com/")

    # load them
    client_secrets = Google::APIClient::ClientSecrets.load(path)

    auth = client_secrets.to_authorization
    auth.update!(
      scope: 'https://www.googleapis.com/auth/cloudprint',
      redirect_uri: CALLBACK_URL,
      access_type: 'offline',
      response_type: 'code'
    )
    auth
  end

  def self.refresh_token
    auth = auth_client(token_path)
    auth.refresh!
    write_token(auth)
  end

  def self.fetch_token
    oauth_url = auth_client(secrets_path).authorization_uri.to_s

    $stderr.puts "Opening the following URL in your default browser. If it doesn't open, please open the link on your own:\n#{oauth_url}"

    if Gem.win_platform?
      puts `start "" "#{oauth_url}"`
    elsif RUBY_PLATFORM =~ /darwin/
      puts `open "#{oauth_url}"`
    else # linux
      puts `xdg-open "#{oauth_url}"`
    end

    start_callback_thread.join
  end

  def self.start_callback_thread
    server = WEBrick::HTTPServer.new Port: 8000, DocumentRoot: File.expand_path('.')

    server.mount_proc '/callback' do |req, res|
      auth = auth_client(secrets_path)
      auth.code = req.query['code']
      auth.fetch_access_token!

      $stderr.puts "writing token to #{token_path}"
      write_token(auth)
      res.body = "Credentials written to #{token_path}. You may close this browser tab."
      server.stop
    end

    $stderr.puts 'Server started in background to receive OAuth callback...'
    Thread.new do
      server.start
    end
  end

  def self.write_token(auth)
    File.open(token_path, 'w') { |f| f << %Q{{"installed":#{auth.to_json}}}}
  end

  def self.submit_job(*args)

    https://www.google.com/cloudprint/submit
  end
end

# internal libs
require 'gcp_directory/version'
require 'gcp_directory/printer'
require 'gcp_directory/listener'
