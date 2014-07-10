require 'test_helper'

class TransformControllerTest < ActionController::TestCase
  test "should get xls_to_table" do
    get :xls_to_table
    assert_response :success
  end

end
