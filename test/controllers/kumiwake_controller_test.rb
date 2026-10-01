require 'test_helper'
require 'tempfile'

class KumiwakeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/kumiwake'
    assert_response :success
  end

  test 'creates a roster, draws balanced groups, exports CSV, and resets the round' do
    participants = build_list(:participant, 5)
    names = participants.map { |participant| participant['name'] }

    post '/kumiwake/save_names', params: { names: names }
    assert_redirected_to '/kumiwake'
    follow_redirect!
    assert_select "p[data-names-count='5']"

    post '/kumiwake/save_group_names', params: { group_names: ['赤組', ''] }
    post '/kumiwake/draw', params: { avoid_repeat_mode: 'false' }
    follow_redirect!
    assert_response :success
    assert_equal [2, 3], css_select('.group-result').map { |group| group.css('p').size }.sort
    assert_equal 5, css_select('.group-result p').size

    get '/csv/export'
    assert_response :success
    assert_includes response.headers['Content-Disposition'], 'kumiwake.csv'
    assert_includes response.body, '赤組'
    assert_includes response.body, 'B組'

    post '/kumiwake/reset_history'
    assert_response :no_content
    get '/kumiwake/result'
    assert_redirected_to '/kumiwake'
  end

  test 'removes blank names before drawing' do
    post '/kumiwake/save_names', params: { names: ['太郎', '', '次郎'] }
    post '/kumiwake/save_group_names', params: { group_names: ['全員'] }
    post '/kumiwake/draw', params: { avoid_repeat_mode: 'false' }
    follow_redirect!

    assert_equal %w[太郎 次郎], css_select('.group-result p').map { |node| node.text.strip }.sort
  end

  test 'imports names from a CSV file' do
    file = Tempfile.new(['names', '.csv'])
    file.write("名前\n太郎\n次郎\n")
    file.close

    post '/csv/import', params: {
      file: Rack::Test::UploadedFile.new(file.path, 'text/csv')
    }

    assert_redirected_to '/kumiwake'
    follow_redirect!
    assert_select "p[data-names-count='2'][data-from-input='true']"
  ensure
    file&.unlink
  end

  test 'result page shows round number in magic mode and after continuing normally' do
    post '/kumiwake/save_names', params: { names: %w[太郎 次郎 三郎 四郎] }
    post '/kumiwake/save_group_names', params: { group_names: %w[A B] }

    post '/kumiwake/draw', params: { avoid_repeat_mode: 'true' }
    follow_redirect!
    assert_select 'h1', /第1回目/

    post '/kumiwake/draw', params: { switch_to_normal: 'true' }
    follow_redirect!
    assert_select 'h1', /第2回目/
  end

  test 'history button appears from the second magic round and is hidden in normal mode' do
    post '/kumiwake/save_names', params: { names: %w[太郎 次郎 三郎 四郎 五郎 六郎] }
    post '/kumiwake/save_group_names', params: { group_names: %w[A B C] }

    post '/kumiwake/draw', params: { avoid_repeat_mode: 'true' }
    follow_redirect!
    assert_select 'h1', /第1回目/
    assert_select 'a.history-button', 0
    assert_select "form[data-turbo='false']", 1

    post '/kumiwake/draw', params: { avoid_repeat_mode: 'true' }
    follow_redirect!
    assert_select 'h1', /第2回目/
    assert_select 'a.history-button', 1

    get '/kumiwake/history'
    assert_response :success
    assert_select 'h1', /組み分け履歴/

    get '/kumiwake/result'
    assert_response :success

    post '/kumiwake/draw', params: { switch_to_normal: 'true', avoid_repeat_mode: 'false' }
    follow_redirect!
    assert_select 'h1', /第3回目/
    assert_select 'a.history-button', 0
  end

  test 'latest result remains available after opening history' do
    post '/kumiwake/save_names', params: { names: %w[太郎 次郎 三郎 四郎] }
    post '/kumiwake/save_group_names', params: { group_names: %w[A B] }

    post '/kumiwake/draw', params: { avoid_repeat_mode: 'true' }
    follow_redirect!
    assert_select 'h1', /第1回目/

    get '/kumiwake/history'
    assert_response :success

    get '/kumiwake/result'
    assert_response :success
    assert_select 'h1', /組み分け結果/
  end

  test 'continuing after limit switches to normal mode' do
    post '/kumiwake/save_names', params: { names: %w[太郎 次郎 三郎 四郎] }
    post '/kumiwake/save_group_names', params: { group_names: %w[A B] }

    3.times do |round|
      post '/kumiwake/draw', params: { avoid_repeat_mode: 'true' }
      follow_redirect!
      assert_select 'h1', /第#{round + 1}回目/
    end

    post '/kumiwake/draw', params: { switch_to_normal: 'true', avoid_repeat_mode: 'false' }
    follow_redirect!
    assert_select 'h1', /第4回目/
    assert_select 'a.history-button', 0
  end

  test 'limit is shown after returning from history' do
    post '/kumiwake/save_names', params: { names: %w[太郎 次郎 三郎 四郎] }
    post '/kumiwake/save_group_names', params: { group_names: %w[A B] }

    3.times do
      post '/kumiwake/draw', params: { avoid_repeat_mode: 'true' }
      follow_redirect!
    end

    get '/kumiwake/history'
    assert_response :success

    get '/kumiwake/result'
    assert_response :success

    post '/kumiwake/draw'
    assert_redirected_to '/kumiwake'
    follow_redirect!
    assert_select "p[data-limit-reached='true']"
  end

  test 'normal mode does not grow the stored history' do
    post '/kumiwake/save_names', params: { names: %w[太郎 次郎 三郎 四郎] }
    post '/kumiwake/save_group_names', params: { group_names: %w[A B] }

    post '/kumiwake/draw', params: { avoid_repeat_mode: 'true' }
    follow_redirect!

    post '/kumiwake/draw', params: { switch_to_normal: 'true', avoid_repeat_mode: 'false' }
    follow_redirect!

    20.times do
      post '/kumiwake/draw', params: { avoid_repeat_mode: 'false' }
      follow_redirect!
    end

    assert_select 'h1', /第22回目/

    get '/kumiwake/history'
    assert_select '.history-item', 0
    assert_select '.no-history', 1
  end
end

class KumiwakeControllerSessionTest < ActionController::TestCase
  tests KumiwakeController

  test 'migrates the legacy mode key' do
    session[:magic_mode] = false

    get :index

    assert_nil session[:magic_mode]
    assert_equal false, session[:avoid_repeat_mode]
  end

  test 'starting a new round clears the previous limit state' do
    session[:avoid_repeat_mode] = true
    session[:kumiwake_limit_reached] = true
    session[:group_history] = ['1:2']

    get :index, params: { new: 'true' }

    assert_nil session[:kumiwake_limit_reached]
    assert_nil session[:avoid_repeat_mode]
    assert_nil session[:group_history]
  end
end
