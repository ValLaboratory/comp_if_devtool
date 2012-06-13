# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../lib/v2apiDevTool/")

gem "test-unit"
require "test/unit"
require "models/config"

class ConfigTest < Test::Unit::TestCase
  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_ROOT = File.join(TEST_DIR,"..")
  # 本番ディレクトリ
  APP_ROOT = File.join(TEST_ROOT,"..","lib","v2apiDevTool")

  def setup
    config_expand_path = File.join(TEST_ROOT,"config")
    @config = V2apiDevTool::Model::Config.new(config_expand_path)
  end

  def test_exist_app_config_debug?
    assert_equal(@config.exist_app_config_debug?,true)
  end

  def test_load_app_config
    contents = nil
    assert_nothing_raised do
      contents = @config.load_app_config
    end
    assert_equal(contents.class,Hash)
    assert_not_nil(contents["v2apiURL"])
  end

  def test_load_app_config_debug
    contents = nil
    assert_nothing_raised do
      contents = @config.load_app_config_debug
    end
    assert_equal(contents.class,Hash)
  end
end
