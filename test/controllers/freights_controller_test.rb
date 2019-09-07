require 'test_helper'

class FreightsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get freights_index_url
    assert_response :success
  end

end
