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

  test "history button appears from the second magic round and is hidden in normal mode" do
    post "/kumiwake/save_names", params: { names: ["太郎", "次郎", "三郎", "四郎", "五郎", "六郎"] }
    post "/kumiwake/save_group_names", params: { group_names: ["A", "B", "C"] }

    post "/kumiwake/draw", params: { magic_mode: "true" }
    follow_redirect!
    assert_select "h1", /第1回目/
    assert_select "a.history-button", 0
    assert_select "form[data-turbo='false']", 1

    post "/kumiwake/draw", params: { magic_mode: "true" }
    follow_redirect!
    assert_select "h1", /第2回目/
    assert_select "a.history-button", 1

    get "/kumiwake/history"
    assert_response :success
    assert_select "h1", /組み分け履歴/

    get "/kumiwake/result"
    assert_response :success

    post "/kumiwake/draw", params: { switch_to_normal: "true", magic_mode: "false" }
    follow_redirect!
    assert_select "h1", /第3回目/
    assert_select "a.history-button", 0
  end

  test "history back link returns to latest result instead of name input" do
    post "/kumiwake/save_names", params: { names: ["太郎", "次郎", "三郎", "四郎"] }
    post "/kumiwake/save_group_names", params: { group_names: ["A", "B"] }

    post "/kumiwake/draw", params: { magic_mode: "true" }
    follow_redirect!
    assert_select "h1", /第1回目/

    session[:current_groups] = nil
    get "/kumiwake/result"
    assert_response :success
    assert_select "h1", /組み分け結果/
  end

  test "continuing after limit switches to normal mode" do
    post "/kumiwake/save_names", params: { names: ["太郎", "次郎", "三郎", "四郎"] }
    post "/kumiwake/save_group_names", params: { group_names: ["A", "B"] }

    session[:magic_mode] = true
    session[:group_history] = [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    session[:kumiwake_limit_reached] = true

    post "/kumiwake/draw", params: { switch_to_normal: "true", magic_mode: "false" }
    follow_redirect!
    assert_select "h1", /第1回目/
    assert_select "a.history-button", 0
  end

  test "limit is shown after returning from history" do
    post "/kumiwake/save_names", params: { names: ["太郎", "次郎", "三郎", "四郎"] }
    post "/kumiwake/save_group_names", params: { group_names: ["A", "B"] }

    3.times do
      post "/kumiwake/draw", params: { magic_mode: "true" }
      follow_redirect!
    end

    get "/kumiwake/history"
    assert_response :success

    get "/kumiwake/result"
    assert_response :success

    post "/kumiwake/draw"
    assert_redirected_to "/kumiwake"
    follow_redirect!
    assert_select "p[data-limit-reached='true']"
  end

  test "normal mode does not grow the stored history" do
    post "/kumiwake/save_names", params: { names: ["太郎", "次郎", "三郎", "四郎"] }
    post "/kumiwake/save_group_names", params: { group_names: ["A", "B"] }

    post "/kumiwake/draw", params: { magic_mode: "true" }
    follow_redirect!

    post "/kumiwake/draw", params: { switch_to_normal: "true", magic_mode: "false" }
    follow_redirect!
    magic_history_count = session[:past_results].length

    20.times do
      post "/kumiwake/draw", params: { magic_mode: "false" }
      follow_redirect!
    end

    assert_equal magic_history_count, session[:past_results].length
    assert_equal 22, session[:draw_count]
  end
end
