require_relative "server/port"

module HttpTest::Server
  extend self

  # Kills the current server process and checks that the port becomes unavailable.
  def kill!
    return unless @pid

    Process.kill("TERM", @pid)
    Process.wait

    if @port && Port.available?(@port)
      STDERR.puts "Warning: Could not stop server at #{url_base}"
    end

    @port = nil
    @pid = nil
  end

  def url_base
    "http://127.0.0.1:#{@port}"
  end

  def start!(command)
    return if @started == command && @port

    kill! if @started

    started_at = Time.now

    @port = Port.choose

    @pid = fork do
      # Signal.trap("HUP") { STDERR.puts "Exiting web server"; exit }
      # # ... do some work ...
      ENV["RACK_ENV"] = "test"
      ENV["PORT"] = @port.to_s

      exec command
    end

    Port.wait(@port)

    secs = Time.now - started_at
    STDERR.puts "\n[http-test##{@pid}] test server '#{command}' running on #{url_base} after #{'%.3f secs' % secs}"

    @started = command
  end
end

at_exit do
  HttpTest::Server.kill!
end
