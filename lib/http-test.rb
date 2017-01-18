require "test-unit"
require "forwardable"

module HttpTest
  # A session of the test server.
  class Session
    attr_reader :url_base
    attr_reader :command

    def initialize(url_base: nil, command: nil)
      @url_base = url_base
      @command  = command
    end

    def start!
      return unless @command

      port = Server.start! @command
      @url_base = "http://localhost:#{port}"
    end
  end

  def self.stop_session
    @session = nil
  end

  def self.start_session(session)
    session.start!
    @session = session
  end

  def self.url_base
    return @session.url_base if @session

    STDERR.puts <<-MSG
Either define a API endpoint via url_base <url>, or define a command to start a test_server via test_server "command"'
    MSG
    #STDERR.puts "called from\n\t#{caller[0,6].join("\n\t")}"
    raise "Missing session definition"
  end

  # ---------------------------------------------------------------------------

  module TestUnitAdapter
    module ClassMethods
      attr_accessor :session_parameters
    end

    def self.extended(base)
      base.extend ClassMethods
    end

    def url_base(url_base)
      class << self
        def startup
          HttpTest.start_session(session_parameters)
        end

        def shutdown
          HttpTest.stop_session
        end
      end

      self.session_parameters = Session.new url_base: url_base
    end

    def test_server(command)
      class << self
        def startup
          HttpTest.start_session(session_parameters)
        end

        def shutdown
          HttpTest.stop_session
        end
      end

      self.session_parameters = Session.new command: command
    end
  end
end

require_relative "http-test/http_methods"
require_relative "http-test/server"

class HttpTest::TestCase < Test::Unit::TestCase
  include HttpTest::HttpMethods # include HTTP helper methods, like GET, PUT etc.
  extend HttpTest::TestUnitAdapter
end
