# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "rack/test"
require "nokogiri"
require "app"

ENV['RACK_ENV'] = 'test'

class CgiRedirectControllerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    V2apiDevTool::V2apiDevToolApp
  end

  # 存在しないAPIの場合
  def test_cgi_redirect_controller_invalid
    params = {
      "val_from"=>"西国分寺",
      "val_to"=>"海芝浦",
      "val_htmb"=>"cgi_invalid",
      "val_v2api_dev_tool_request_server"=>"http://intra.val.co.jp/expwww2/expcgi.exe"}
    #post "/cgi_hoge/output", params
    # エラー時の処理を実装後に作成
  end


  # レスポンスボディの内容一致判定
  #   doc -> レスポンスボディの内容(Nokogiri::HTML)
  #   params -> リクエストされたパラメータ
  #   charset -> metaタグのcharset属性の値
  def assert_response_document(doc,params,charset)
    # -------------- head --------------
    head = doc.css("head")[0]
    meta = head.css("meta")[0]
    assert_equal(meta["charset"],charset)
    scripts = head.css("script")
    assert(scripts.length > 1)  # submitを動作させられるものがあるかどうか
    title = head.css("title")
    assert(title.length == 1)


    # -------------- body --------------
    form = doc.css("body #input_param_form")[0]
    assert(form["action"])
    assert_equal(form["method"].upcase,"POST")
    inputs = form.css("input")
    assert_equal(inputs.length,params.length - 1)
    inputs.each do |input|
      name = input["name"]
      assert_not_equal(name,"val_v2api_dev_tool_request_server")  # 削除されていることを確認
      assert_equal(input["type"],"hidden")
      assert_equal(input["value"],params[name])
    end
  end

  # 存在するAPIの場合(CP932)
  def test_cgi_redirect_controller_cgi_details2_cp932
    params = {
      "val_htmb" => "cgi_details2",
      "val_from" => "西国分寺",
      "val_to" => "海芝浦",
      "user" => "param",
      "val_v2api_dev_tool_request_server" => "http://intra.val.co.jp/expwww2/expcgi.exe"}
    post "/cgi_details2/output", params

    # ============== レスポンスヘッダ ==============
    assert_equal(last_response.headers["Content-Type"],"text/html;charset=shift_jis")
    assert_equal(last_response.status,200)


    # ============== レスポンスボディ ==============
    assert_equal(last_response.body.encoding.name,"Windows-31J")
    doc = Nokogiri::HTML(last_response.body.encode("utf-8"))

    assert_response_document(doc,params,"Shift_JIS")
  end

  # 存在するAPIの場合(UTF-8)
  def test_cgi_redirect_controller_cgi_details2_utf8
    params = {
      "val_htmb" => "cgi_details2",
      "val_from" => "西国分寺",
      "val_to" => "海芝浦",
      "val_encode" => "utf-8",
      "user" => "param",
      "val_v2api_dev_tool_request_server" => "http://intra.val.co.jp/expwww2/expcgi.exe"}
    post "/cgi_details2/output", params

    # ============== レスポンスヘッダ ==============
    assert_equal(last_response.headers["Content-Type"],"text/html;charset=utf-8")
    assert_equal(last_response.status,200)


    # ============== レスポンスボディ ==============
    assert_equal(last_response.body.encoding.name,"UTF-8")
    doc = Nokogiri::HTML(last_response.body)

    assert_response_document(doc,params,"UTF-8")
  end
end
