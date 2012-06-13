# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "rack/test"
require "yaml"
require "nokogiri"
require "app"

ENV['RACK_ENV'] = 'test'

class CgiOutputControllerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_DATA = File.join(TEST_DIR,"test_data")

  def app
    V2apiDevTool::V2apiDevToolApp
  end


  # レスポンスボディの内容一致判定
  #   doc -> レスポンスボディの内容(Nokogiri::HTML)
  #   params -> リクエストされたパラメータ
  def assert_response_document(doc,params)
    route_cnt = params["val_route_cnt"].to_i

    container = doc.css("body #container")

    # header
    header = container.css("#header")
    assert(header.length == 1)
    # footer
    footer = container.css("#footer")
    assert(footer.length == 1)


    contents = container.css("#contents_output")[0]
    # 経路サマリー
    summary_table = contents.css("#output_summary_table")
    assert_equal(summary_table.length,1)
    summary_trs = summary_table[0].css("tr")
    assert_equal(summary_trs.length,route_cnt + 1)

    # メインテーブル
    param_table = container.css("#output_param_table")
    assert_equal(param_table.length,1)
    param_trs = param_table[0].css("tr")
    th_name_col = param_trs[0].css("th.name_col")[0]
    column_base_num = th_name_col["colspan"].to_i + 2  # カラム数(colspanで結合されている数含む)
    param_trs.each do |tr|
      tds = tr.css("td")
      if tds.length == 0 then next end

      # カラム数チェック
      column_num = 0
      tds.each do |td|
        column_num += td["colspan"] ? td["colspan"].to_i : 1
      end
      assert_equal(column_num,column_base_num)

      # 内容チェック
      name_cols = tds.css(".name_col")
      assert_equal(name_cols.length,1)
      name = name_cols[0].text
      value = tds.css(".value_col")[0].text
      assert_equal(params[name],value)
    end

    # ユーザーパラメータテーブル
    user_param_table = container.css("#output_user_param_table")
    assert_equal(user_param_table.length,1)
    user_param_trs = user_param_table[0].css("tr")
    user_param_trs.each do |tr|
      tds = tr.css("td")
      if tds.length == 0 then next end

      # 内容チェック
      name_cols = tds.css(".name_col")
      assert_equal(name_cols.length,1)
      name = name_cols[0].text
      value = tds.css(".value_col")[0].text
      assert_equal(params[name],value)
    end

    # 未定義パラメータテーブル
    notdef_param_table = container.css("#output_notdef_param_table")
    assert_equal(notdef_param_table.length,1)
    notdef_param_trs = notdef_param_table[0].css("tr")
    notdef_param_trs.each do |tr|
      tds = tr.css("td")
      if tds.length == 0 then next end

      # 内容チェック
      name_cols = tds.css(".name_col")
      assert_equal(name_cols.length,1)
      name = name_cols[0].text
      value = tds.css(".value_col")[0].text
      assert_equal(params[name],value)
    end
  end


  # CP932の場合
  def test_cgi_output_controller_cgi_details2_cp932
    params = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2_cp932.yml"))

    # postパラメータをCP932に変換
    params_cp932 = {}
    params.each do |key,value|
      params_cp932[key.encode("cp932")] = value.encode("cp932")
    end
    post "/cgi_details2/output", params_cp932

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
    assert_response_document(doc,params)
  end


  # UTF-8の場合
  def test_cgi_output_controller_cgi_details2_utf8
    params = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2_utf8.yml"))

    post "/cgi_details2/output", params

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
    assert_response_document(doc,params)
  end
end
