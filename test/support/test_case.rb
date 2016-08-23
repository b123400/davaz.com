require 'util/app'
require 'util/drbserver'

module DaVaz
  module TestCase
    attr_reader :browser

    def before_setup
      super
      startup_server
      boot_browser
    end

    def after_teardown
      close_browser
      shutdown_server
      super
    end

    private

    def startup_server
      return if @server
      at_exit { shutdown_server }

      drb_url = TEST_APP_URI.to_s
      app = DaVaz::Util::App.new
      app.db_manager = DaVaz::Stub::DbManager.new
      app.yus_server = DaVaz::Stub::YusServer.new

      server = DaVaz::Util::DRbServer.new(app)
      @drb = Thread.new do
        begin
          @drb_server = DRb.start_service(drb_url, server)
        rescue Exception => e
          $stdout.puts e.class
          $stdout.puts e.message
          $stdout.puts e.backtrace
          raise
        end
      end
      @drb.abort_on_exception = true
      trap('INT') { @drb_server.stop_service; @drb.exit }

      @http_server = Stub.http_server(drb_url)
      @http_server.shutdown
      trap('INT') { @http_server.shutdown }

      @server = Thread.new { @http_server.start }
      trap('INT') { @server.exit }
    end

    def boot_browser
      return if @browser
      at_exit { close_browser }

      @browser = DaVaz::Browser.new
      trap('INT') { @browser.close }
    end

    def shutdown_server
      return unless @server

      @http_server.shutdown
      @http_server = nil
      @drb_server.stop_service
      @drb_server = nil
      @drb.exit
      @drb = nil
      @server.exit
      @server = nil
    end

    def close_browser
      return unless @browser

      begin
        @browser.close
      rescue Errno::ECONNREFUSED
      end
      @browser = nil
    end
  end
end
