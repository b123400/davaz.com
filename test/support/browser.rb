require 'selenium-webdriver'
require 'watir'

module DaVaz
  class Browser < SimpleDelegator

    def initialize
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = 30
      path = File.expand_path(
        '../../../node_modules/phantomjs-prebuilt/bin/phantomjs', __FILE__)
      Selenium::WebDriver::PhantomJS.path = path
      phantomjs_args = [
        '--debug=true',
        '--web-security=false',
        '--load-images=false',
        '--ignore-ssl-errors=true'
      ]
      @browser = Watir::Browser.new(
        :phantomjs, args: phantomjs_args, http_client: client)
      super @browser
    end

    def visit(path)
      @browser.goto(TEST_SRV_URI.to_s + path)
    end
  end
end
