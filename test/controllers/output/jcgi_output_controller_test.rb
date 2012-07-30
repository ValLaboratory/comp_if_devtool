# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "rack/test"
require "webmock/test_unit"
require "nokogiri"
require "app"

ENV['RACK_ENV'] = 'test'

class JcgiOutputControllerTest < Test::Unit::TestCase
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
  def test_jcgi_output_controller_jcgi_details2_cp932
    input_params = {
      "val_htmb" => "jcgi_details2",
      "val_from" => "出雲市",
      "val_to01" => "長野",
      "val_to02" => "直江津",
      "val_to03" => "燕三条",
      "val_to04" => "村上(新潟県)",
      "val_feeling" => "3121122",
      "val_max_result" => "3",
      "val_v2api_dev_tool_request_server" => "http://intra.val.co.jp/expwww2/expcgi.exe"}
    request_server = input_params["val_v2api_dev_tool_request_server"]

    # postパラメータをCP932に変換し、クエリ文字列に
    input_params_for_mock_cp932 = {}
    input_params.each do |key,value|
      next if key == "val_v2api_dev_tool_request_server"  # カットされるので無視
      input_params_for_mock_cp932[key] = value.encode("cp932")
      # webmockがUTF-8(ソースエンコーディング)で比較しようとするので強制変換
      input_params_for_mock_cp932[key].force_encoding("utf-8")
    end

    # レスポンスのhtml(ていうかテキスト)
    jcgi_response = "".encode("cp932")
    File.open(File.join(TEST_DATA,"response_sample_jcgi_details2_cp932.html"),"rt:cp932") do |f|
      f.each do |line|
        jcgi_response += line
      end
    end
    jcgi_response_utf8 = jcgi_response.encode("utf-8")
    params = jcgi_response_utf8.split("&")
    result = params.map do |param|
      param.split("=",2)
    end
    output_params = Hash[result]

    # JCGIリクエスト時のモックの設定
    WebMock.stub_request(:post,request_server)
      .with(:body => input_params_for_mock_cp932)
      .to_return(:body => jcgi_response)

    post "/jcgi_details2/output", input_params
    # 1回リクエストがあったことを確認
    WebMock.assert_requested(:post,request_server,:times => 1)

    # ============== レスポンスヘッダ ==============
    # モックで設定しないので省略


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
    assert_response_document(doc,output_params)
  end

  # UTF-8の場合
  def test_jcgi_output_controller_jcgi_details2_utf8
    input_params = {
      "val_htmb" => "jcgi_details2",
      "val_from" => "出雲市",
      "val_to01" => "長野",
      "val_to02" => "直江津",
      "val_to03" => "燕三条",
      "val_to04" => "村上(新潟県)",
      "val_feeling" => "3121122",
      "val_max_result" => "3",
      "val_encode" => "utf-8",
      "val_v2api_dev_tool_request_server" => "http://intra.val.co.jp/expwww2/expcgi.exe"}
    request_server = input_params["val_v2api_dev_tool_request_server"]

    # モック実行時のパラメータ(イントラサーバにリクエストする段階)
    input_params_for_mock = input_params.dup
    input_params_for_mock.delete("val_v2api_dev_tool_request_server")

    # レスポンスのhtml(ていうかテキスト)
    jcgi_response = ""
    File.open(File.join(TEST_DATA,"response_sample_jcgi_details2_utf8.html"),"rt:utf-8") do |f|
      f.each do |line|
        jcgi_response += line
      end
    end
    params = jcgi_response.split("&")
    result = params.map do |param|
      param.split("=",2)
    end
    output_params = Hash[result]

    # JCGIリクエスト時のモックの設定
    WebMock.stub_request(:post,request_server)
      .with(:body => input_params_for_mock)
      .to_return(:body => jcgi_response)

    post "/jcgi_details2/output", input_params
    # 1回リクエストがあったことを確認
    WebMock.assert_requested(:post,request_server,:times => 1)

    # ============== レスポンスヘッダ ==============
    # モックで設定しないので省略


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
    assert_response_document(doc,output_params)
  end
end
