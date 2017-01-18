require "test-unit"
require "forwardable"

module HttpTest
  def self.start_session(session_parameters)
    url_base, command = session_parameters.values_at :url_base, :command
    @session = Session.start! url_base: url_base, command: command
  end

  def self.stop_session
    @session = nil
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

      self.session_parameters = { url_base: url_base }
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

      self.session_parameters = { command: command }
    end
  end
end

require_relative "http-test/http_methods"
require_relative "http-test/session"

class HttpTest::TestCase < Test::Unit::TestCase
  include HttpTest::HttpMethods # include HTTP helper methods, like GET, PUT etc.
  extend HttpTest::TestUnitAdapter
end
