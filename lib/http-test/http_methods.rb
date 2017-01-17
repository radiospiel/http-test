require "faraday"

require "net/http"
require "json"

# :status - HTTP response status code, such as 200
# :body   - the response body
# :response_headers
#
#
module HttpTest::HttpMethods
  module Response
    module FaradayHelper
      attr_accessor :faraday_response

      extend Forwardable
      delegate [:status, :body, :headers] => :faraday_response

      alias code status
    end

    class BlankResponse
      include FaradayHelper

      def initialize(faraday_response)
        self.faraday_response = faraday_response
      end
    end

    def self.create(faraday_response)
      body, headers = faraday_response.body, faraday_response.headers
      return BlankResponse.new(faraday_response) unless body && body.length > 0

      response = case content_type = headers["content-type"]
      when /\Aapplication\/json/ then JSON.parse faraday_response.body
      when /\Atext\//            then faraday_response.body
      else                            raise "unsupported content_type: #{content_type.inspect}"
      end

      response.extend FaradayHelper
      response.faraday_response = faraday_response
      response
    end
  end

  def url(path)
    return path if path =~ /\Ahttp(s)?:/

    File.join(HttpTest.url_base, path)
  end

  # rubocop:disable Style/MethodName
  def HEAD(path)
    @response = Response.create Faraday.head(url(path))
  end

  def GET(path)
    @response = Response.create Faraday.get(url(path))
  end

  def POST(path, body = {})
    @response = Response.create Faraday.post(url(path), body)
  end

  def PUT(path, body = {})
    @response = Response.create Faraday.put(url(path), body)
  end

  def DELETE(path)
    @response = Response.create Faraday.delete(url(path))
  end

  attr_reader :response

  def asset_redirect_to(url)
    assert_equal(302, response.code)
    assert_equal(url, response.headers["location"])
  end
end
