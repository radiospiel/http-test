# Http::Test

The `http-test` ruby gem lets you define HTTP API tests in ruby code. Note that the server can be 
implemented any way you want, as long as it is either available on a proper URL, or can be started
in non-daemonized mode with a single command.

## Running HTTP tests against a remove server

    require_relative "./test_helper"

    class RemoteHttpTest < HttpTest::TestCase
      url_base "http://jsonplaceholder.typicode.com"

      def test_get
        GET "/posts/1"
        assert_equal(200, response.status)
        assert_equal(1, response["userId"])
      end

      def test_head
        HEAD "/posts/1"
        assert_equal(200, response.status)
        assert(response.body.empty?)
      end

      def test_post
        POST "/posts", title: "test title", body: "test body"
        assert_equal(201, response.status)
        assert_equal("test title", response["title"])
      end

      def test_put
        PUT "/posts/1", title: "new title"
        assert_equal(200, response.status)
      end

      def test_delete
        DELETE "/posts/1"
        assert_equal(200, response.status)
      end
    end

## Running HTTP tests against a local server

test-http can also be used to run tests against a local test server. For this, the
you must define a command to start the server. For this mode you must define a command
to start the server in a non-daemonized mode.

    class LocalHttpTest < HttpTest::TestCase
      test_server "#{File.dirname(__FILE__)}/local-http"
      ...
    end

**Limitations:**

- test servers are always running locally. The port is determined randomly by http-test.
- The command must read the PORT environment value to determine which port to listen on.
- When being killed the command must kill all its children. For simple servers this is not a problem; for daemonizing servers or servers that start worker processes you might want to add a shell script which sets up servers correctly. This, for example, is a script which properly deals with a phoenix server:

        #!/bin/bash
        set -eu
        
        HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        cd $HERE
        
        _term() { 
          echo "Caught SIGTERM signal!" 
          kill -TERM "$child" 2>/dev/null
        }
        
        trap _term SIGTERM
        mix phoenix.server &
        
        child=$! 
        wait "$child"

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Some of these tests talk to a remote server at http://jsonplaceholder.typicode.com. To skip these tests run rake with the following command:

    SKIP_REMOTE_TESTS=1 rake

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/radiospiel/http-test.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

