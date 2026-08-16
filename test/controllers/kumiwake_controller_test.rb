require "test_helper"

class KumiwakeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/kumiwake"
    assert_response :success
  end

  test "result page shows round number in magic mode and after continuing normally" do
    post "/kumiwake/save_names", params: { names: ["太郎", "次郎", "三郎", "四郎"] }
    post "/kumiwake/save_group_names", params: { group_names: ["A", "B"] }

    post "/kumiwake/draw", params: { magic_mode: "true" }
    follow_redirect!
    assert_select "h1", /第1回目/

    post "/kumiwake/draw", params: { switch_to_normal: "true" }
    follow_redirect!
    assert_select "h1", /第2回目/
  end
end
