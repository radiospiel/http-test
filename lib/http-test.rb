require "test-unit"
require "forwardable"

module HttpTest
  PORT = 4444

  def self.url_base(url_base = nil)
    @url_base = url_base if url_base
    return @url_base if @url_base
    STDERR.puts <<-MSG
Either define a API endpoint via url_base <url>, or define a command to start a test_server via test_server "command"'
    MSG
    exit 1
  end

  def self.test_server(command)
    Server.start!(command)
    url_base "http://localhost:#{PORT}"
  end

  module TestUnitAdapter
    extend Forwardable

    delegate url_base: HttpTest
    delegate test_server: HttpTest
  end
end

require_relative "http-test/http_methods"
require_relative "http-test/server"

class HttpTest::TestCase < Test::Unit::TestCase
  include HttpTest::HttpMethods # include HTTP helper methods, like GET, PUT etc.
  extend HttpTest::TestUnitAdapter
end
