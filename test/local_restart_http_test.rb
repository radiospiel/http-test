require_relative "./test_helper"

class LocalRestartHttpTest < HttpTest::TestCase
  test_server "VERSION=2 #{File.dirname(__FILE__)}/local-http"

  def test_get
    GET "/posts/1"
    assert_equal(200, response.status)
    assert_equal("2", response["version"])
  end
end
