require_relative "./test_helper"

class LocalHttpTest < HttpTest::TestCase
  test_server "#{File.dirname(__FILE__)}/local-http"

  def test_get
    GET("/posts/1")
    assert_equal(200, response.status)
    assert_equal(1, response["userId"])
  end

  def test_head
    HEAD("/posts/1")
    assert_equal(200, response.status)
    assert(response.body.empty?)
  end

  def test_post
    POST("/posts", title: "test title", body: "test body")
    assert_equal(201, response.status)
    assert_equal("test title", response["title"])
  end

  def test_put
    PUT("/posts/1", title: "new title")
    assert_equal(200, response.status)
  end

  def test_delete
    DELETE("/posts/1")
    assert_equal(200, response.status)
  end
end
