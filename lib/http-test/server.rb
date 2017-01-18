require "socket"
require "timeout"

module HttpTest::Server
  extend self

  PORT = 4444

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

  def kill!
    STDERR.puts "Killing #{@pid}"

    return unless @pid

    Process.kill("TERM", @pid)
    Process.wait
    
    if available?
      STDERR.puts "Could not stop server"
      exit 1
    end

    @pid = nil
  end

  def start!(command)
    return PORT if @started == command

    kill! if @started

    @pid = fork do
      # Signal.trap("HUP") { STDERR.puts "Exiting web server"; exit }
      # # ... do some work ...
      ENV["RACK_ENV"] = "test"
      ENV["PORT"] = PORT.to_s

      exec command
    end

    STDERR.puts "[http-test] Trying to start test server via '#{command}', as pid: #{@pid}"

    wait_for_port
    @started = command
    PORT
  end
end

at_exit do
  HttpTest::Server.kill!
end
