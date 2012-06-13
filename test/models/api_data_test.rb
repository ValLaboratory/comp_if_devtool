# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "models/api_data"

class ApiDataTest < Test::Unit::TestCase
  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_ROOT = File.join(TEST_DIR,"..")
  # 本番ディレクトリ
  APP_ROOT = File.join(TEST_ROOT,"..","lib","v2apiDevTool")

  def setup
    api_data_expand_path = File.join(APP_ROOT,"data/api")
    @api_data = V2apiDevTool::Model::ApiData.new(api_data_expand_path)
  end

  def test_load_v2apis
    contents = nil
    assert_nothing_raised do
      contents = @api_data.load_v2apis
    end
    assert_equal(contents.class,Hash)
    assert_not_nil(contents["cgi_details2"])
    assert_not_nil(contents["jcgi_details2"])
  end

  def test_load_input_params
    contents = nil
    # 存在しないAPI
    assert_raise do
      @api_data.load_input_params("hoge")
    end

    # API読み込み1
    assert_nothing_raised do
      contents = @api_data.load_input_params("cgi_details2")
    end
    assert_equal(contents.class,Hash)
    assert_not_nil(contents["val_htmb"])
    assert_not_nil(contents["val_cgi_url"])

    # API読み込み2
    assert_nothing_raised do
      contents = @api_data.load_input_params("jcgi_details2")
    end
    assert_equal(contents.class,Hash)
    assert_not_nil(contents["val_htmb"])
    assert_nil(contents["val_cgi_url"])
  end

  def test_load_output_params
    contents = nil
    # 存在しないAPI
    assert_raise do
      @api_data.load_output_params("hoge")
    end

    # API読み込み1
    assert_nothing_raised do
      contents = @api_data.load_output_params("cgi_details2")
    end
    assert_equal(contents.class,Hash)
    assert_not_nil(contents["val_route_cnt"])
    assert_not_nil(contents["val_route_[routeNo]"])

    # API読み込み2
    assert_nothing_raised do
      contents = @api_data.load_output_params("cgi_result2")
    end
    assert_equal(contents.class,Hash)
    assert_not_nil(contents["val_routeno"])
    assert_nil(contents["val_route_[routeNo]"])
  end
end
