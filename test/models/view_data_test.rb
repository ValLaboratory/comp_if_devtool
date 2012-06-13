# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "models/view_data"

class ViewDataTest < Test::Unit::TestCase
  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_ROOT = File.join(TEST_DIR,"..")
  # 本番ディレクトリ
  APP_ROOT = File.join(TEST_ROOT,"..","lib","v2apiDevTool")

  def setup
    view_data_expand_path = File.join(APP_ROOT,"data/view")
    @view_data = V2apiDevTool::Model::ViewData.new(view_data_expand_path)
  end

  def test_load_menu_order
    contents = nil
    assert_nothing_raised do
      contents = @view_data.load_menu_order
    end
    assert_equal(contents.class,Array)
    assert_not_nil(contents[0]["category"])
    assert_not_nil(contents[0]["children"])
  end

  def test_load_input_order
    contents = nil
    assert_nothing_raised do
      contents = @view_data.load_input_order
    end
    assert_equal(contents.class,Array)
    assert_not_nil(contents[0]["groupComment"])
    assert_not_nil(contents[0]["apis"])
    assert_not_nil(contents[0]["params"])
  end

  def test_load_output_order
    contents = nil
    assert_nothing_raised do
      contents = @view_data.load_output_order
    end
    assert_equal(contents.class,Array)
    assert_not_nil(contents[0]["apis"])
    assert_not_nil(contents[0]["params"])
  end
end
