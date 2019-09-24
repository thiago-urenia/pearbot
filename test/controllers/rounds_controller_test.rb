require 'test_helper'

class RoundsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get rounds_create_url
    assert_response :success
  end

end
