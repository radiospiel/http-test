require "socket"
require "timeout"

module HttpTest::Server
  extend self

  PORT = HttpTest::PORT

  def available!(timeout = 0.1)
    s = nil
    Timeout.timeout(timeout) do
      STDERR.print "."
      s = TCPSocket.new("127.0.0.1", PORT)
    end

    STDERR.puts "[http-test] test server became available on http://127.0.0.1:#{PORT}"
  ensure
    s&.close
  end

  def available?(timeout = 0.1)
    available!(timeout)
    true
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
    false
  end

  def wait_for_port(timeout = 10)
    (timeout / 0.1).to_i.times do
      return true if available?(PORT)
      sleep(0.1)
    end

    available!
  end

  def started?
    @started ? true : false
  end

  def start!(command)
    return if started?

    pid = fork do
      # Signal.trap("HUP") { STDERR.puts "Exiting web server"; exit }
      # # ... do some work ...
      ENV["RACK_ENV"] = "test"
      ENV["PORT"] = PORT.to_s

      STDERR.puts "[http-test] Trying to start test server via '#{command}'"
      exec command
    end

    at_exit do
      Process.kill("TERM", pid)
      Process.wait
    end

    wait_for_port
    @started = true
  end
end
