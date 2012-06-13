# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "controllers/output/helpers/output_response"
require "models/models"

class HelperOutputResponseTest < Test::Unit::TestCase
  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_ROOT = File.join(TEST_DIR,"../../..")
  # 本番ディレクトリ
  APP_ROOT = File.join(TEST_ROOT,"..","lib","v2apiDevTool")

  # moduleテスト用のダミークラス
  class HelperOutputResponseDummy
    include V2apiDevTool::Controller::Helper::OutputResponse
  end

  def setup
    @helper_output_response = HelperOutputResponseDummy.new

    # パラメータ表示順データのロード用
    view_data_expand_path = File.join(APP_ROOT,"view/data")
    @view_data = V2apiDevTool::Model::ViewData.new(view_data_expand_path)

    # APIデータのロード用
    api_data_expand_path = File.join(APP_ROOT,"data/api")
    @api_data = V2apiDevTool::Model::ApiData.new(api_data_expand_path)
  end

  def test_load_param_data
    data = nil
    # 存在しないAPI
    assert_raise do
      @helper_output_response.__send__(:load_param_data,"hoge",@api_data)
    end

    # API読み込み
    assert_nothing_raised do
      data = @helper_output_response.__send__(:load_param_data,"cgi_details2",@api_data)
    end
    assert_equal(data,@api_data.load_output_params("cgi_details2"))
    assert_equal(data.class,Hash)
    assert_not_nil(data["val_route_cnt"])
    assert_not_nil(data["val_route_[routeNo]"])
  end
end
