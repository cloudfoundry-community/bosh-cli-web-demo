require 'test_helper'

class HelpControllerTest < ActionDispatch::IntegrationTest
  test "should get version" do
    get help_version_url
    assert_response :success
  end

end
