require_relative "server"

module HttpTest
  # A session of the test server. Note that one might think that a session would
  # holds its own test server instance; we do, however, reuse servers between
  # tests in case multiple test cases use the same test server - which is quite
  # likely the most common use case. 
  class Session
    attr_reader :url_base
    attr_reader :command

    def initialize(url_base: nil, command: nil)
      @url_base = url_base
      @command  = command
    end

    private

    def start!
      return unless @command

      Server.start! @command
      @url_base = Server.url_base
    end

    def self.start!(url_base: nil, command: nil)
      session = Session.new url_base: url_base, command: command
      session.send :start!
      session
    end
  end
end
