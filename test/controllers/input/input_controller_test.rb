# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "rack/test"
require "nokogiri"
require "app"

ENV['RACK_ENV'] = 'test'

class InputControllerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    V2apiDevTool::V2apiDevToolApp
  end

  # 存在しないAPIの場合
  def test_input_controller_invalid
    #get "/cgi_hoge/input"
    # エラー時の処理を実装後に作成
  end


  # group_titleあり、ユーザーパラメータあり
  def test_input_controller_cgi_details2
    get "/cgi_details2/input"

    # ============== レスポンスヘッダ ==============
    assert_equal(last_response.headers["Content-Type"],"text/html;charset=utf-8")
    assert_equal(last_response.status,200)


    # ============== レスポンスボディ ==============
    assert_equal(last_response.body.encoding.name,"UTF-8")
    doc = Nokogiri::HTML(last_response.body)

    # -------------- head --------------
    head = doc.css("head")[0]
    meta = head.css("meta")[0]
    assert_equal(meta["charset"],"UTF-8")
    title = head.css("title")
    assert(title.length == 1)


    # -------------- body --------------
    container = doc.css("body #container")

    # header
    header = container.css("#header")
    assert(header.length == 1)
    # footer
    footer = container.css("#footer")
    assert(footer.length == 1)


    contents = container.css("#contents_input")[0]
    # 履歴ボタン
    history_button = contents.css(".view_history")[0]
    assert_equal(history_button["type"],"button")
    assert_equal(history_button["value"],"履歴")

    # submit用フォーム
    input_param_form = contents.css("#input_param_form")[0]
    assert_equal(input_param_form["action"],"./output")
    assert_equal(input_param_form["method"].upcase,"POST")
    input_submit = input_param_form.css("input")[0]
    assert_equal(input_submit["type"],"submit")

    # 入力テーブル
    input_param_table = contents.css("#input_param_table")[0]
    trs = input_param_table.css("tr")

    # group_title_rowが出力されているか
    group_title_rows = trs.css(".group_title_row")
    group_title_rows.each_with_index do |group_title_row,i|
      assert_equal(group_title_row["id"],"group_#{i}")
    end

    # val_htmbの行
    tr_val_htmb = trs.css(".status_required")[0]
    assert_equal(tr_val_htmb.css("td.name_col").text,"val_htmb")
    value_input = tr_val_htmb.css("td.value_col input")[0]
    assert_equal(value_input["type"],"hidden")
    assert_equal(value_input["class"],"api_input_param")
    assert_equal(value_input["name"],"val_htmb")
    assert_equal(value_input["value"],"cgi_details2")

    # ユーザーパラメータ行
    user_param_additon = trs[-1]
    assert_equal(user_param_additon["class"],"user_param_addition")
    user_param_button = user_param_additon.css("td input")[0]
    assert_equal(user_param_button["class"],"user_param_addition_button")
    assert_equal(user_param_button["type"],"button")
    assert_equal(user_param_button["value"],"ユーザーパラメータを追加")
  end


  # group_titleなし、ユーザーパラメータなし
  def test_input_controller_jcgi_station
    get "/jcgi_station/input"

    # ============== レスポンスヘッダ ==============
    assert_equal(last_response.headers["Content-Type"],"text/html;charset=utf-8")
    assert_equal(last_response.status,200)

    doc = Nokogiri::HTML(last_response.body)


    # ============== レスポンスボディ ==============
    # -------------- body --------------
    container = doc.css("body #container")
    contents = container.css("#contents_input")[0]

    # 入力テーブル
    input_param_table = contents.css("#input_param_table")[0]
    trs = input_param_table.css("tr")

    # group_title_rowが出力されて"いない"か
    group_title_rows = trs.css(".group_title_row")
    assert_equal(group_title_rows.length,0)

    # val_htmbの行
    tr_val_htmb = trs.css(".status_required")[0]
    assert_equal(tr_val_htmb.css("td.name_col").text,"val_htmb")
    value_input = tr_val_htmb.css("td.value_col input")[0]
    assert_equal(value_input["type"],"hidden")
    assert_equal(value_input["class"],"api_input_param")
    assert_equal(value_input["name"],"val_htmb")
    assert_equal(value_input["value"],"jcgi_station")

    # ユーザーパラメータ行が存在しないことを判定
    not_user_param_additon = trs[-1]
    assert_not_equal(not_user_param_additon["class"],"user_param_addition")
  end
end
