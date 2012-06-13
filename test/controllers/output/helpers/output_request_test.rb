# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "controllers/output/helpers/output_request"

class HelperOutputRequestTest < Test::Unit::TestCase
  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_ROOT = File.join(TEST_DIR,"../../..")

  # moduleテスト用のダミークラス
  class OutputRequestHelperDummy
    include V2apiDevTool::Controller::Helper::OutputRequest
  end

  def setup
    @helper_output_request = OutputRequestHelperDummy.new
  end

  def test_delete_devtool_param
    src = {
      "val_htmb" => "jcgi_details2",
      "val_v2api_dev_tool_hoge" => "foo",
      "user_param" => "nanika",
      "val_v2api_dev_tool_from" => "サグラダファミリア",
      "val_to_val_v2api_dev_tool_hoge" => "西国分寺"
    }
    dst = {
      "val_htmb" => "jcgi_details2",
      "user_param" => "nanika",
      "val_to_val_v2api_dev_tool_hoge" => "西国分寺"
    }

    result = @helper_output_request.__send__(:delete_devtool_param,src)
    assert_equal(result,dst)
  end
end
