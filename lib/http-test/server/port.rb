require "socket"
require "timeout"

# helper methods for port handling ---------------------------------------
module HttpTest
  module Server
    module Port
      extend self

      # return an unused port.
      def choose
        server = TCPServer.new('127.0.0.1', 0)
        port = server.addr[1]
      ensure
        # don't know if this is really necessary
        server&.close
      end

      # is a given port available? This raises ECONNREFUSED or EHOSTUNREACH if not,
      # and Timeout::Error if we don't know.
      def available!(port, timeout = 0.1)
        s = nil
        Timeout.timeout(timeout) do
          STDERR.print "."
          s = TCPSocket.new("127.0.0.1", port)
        end
      ensure
        s&.close
      end

      # is a given port available? This returns true if so, and false if not or unsure.
      def available?(port, timeout = 0.1)
        available!(port, timeout)
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
        false
      end

      # wait until a port becomes available. Raises either ECONNREFUSED, EHOSTUNREACH, 
      # or Timeout::Error if the port cannot be established.
      def wait(port, timeout = 10)
        (timeout / 0.1).to_i.times do
          return true if available?(port)
          sleep(0.1)
        end

        available!(port)
      end
    end
  end
end

