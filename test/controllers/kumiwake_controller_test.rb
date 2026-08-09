require "test_helper"

class KumiwakeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get kumiwake_index_url
    assert_response :success
  end
end
