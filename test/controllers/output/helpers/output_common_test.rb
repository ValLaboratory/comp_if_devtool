# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "controllers/output/helpers/output_common"

class HelperOutputCommonTest < Test::Unit::TestCase
  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_ROOT = File.join(TEST_DIR,"../../..")

  # moduleテスト用のダミークラス
  class HelperOutputCommonDummy
    include V2apiDevTool::Controller::Helper::OutputCommon
  end

  def setup
    @helper_output_common = HelperOutputCommonDummy.new
  end

  def test_encode_hash
    # UTF-8
    src_hash = {"キー1" => "ばりゅー1",
                "key2" => "バリュー2",
                "きー3" => "value3",
                "key4" => "value4"}

    dst_hash_932 = @helper_output_common.__send__(:encode_hash,src_hash,"cp932")
    dst_hash_euc = @helper_output_common.__send__(:encode_hash,src_hash,"euc-jp")

    dst_hash_932.each do |key,value|
      assert_equal(key.encoding.name,"Windows-31J")
      assert_equal(value.encoding.name,"Windows-31J")
    end
    dst_hash_euc.each do |key,value|
      assert_equal(key.encoding.name,"EUC-JP")
      assert_equal(value.encoding.name,"EUC-JP")
    end
  end

  def test_convert_www_form_vars
    # val_from=東京&val_to=大宮(埼玉県)&val_htmb=cgi_details2
    src_utf8 = "val_from=%E6%9D%B1%E4%BA%AC&val_to=%E5%A4%A7%E5%AE%AE%28%E5%9F%BC%E7%8E%89%E7%9C%8C%29&val_htmb=cgi_details2"
    src_cp932 = "val_from=%93%8C%8B%9E&val_to=%91%E5%8B%7B%28%8D%E9%8B%CA%8C%A7%29&val_htmb=cgi_details2"

    dst_utf8_to_utf8 = @helper_output_common.__send__(:convert_www_form_vars,src_utf8,"utf-8","utf-8")
    dst_utf8_to_cp932 = @helper_output_common.__send__(:convert_www_form_vars,src_utf8,"utf-8","cp932")
    dst_cp932_to_utf8 = @helper_output_common.__send__(:convert_www_form_vars,src_cp932,"cp932","utf-8")
    dst_cp932_to_cp932 = @helper_output_common.__send__(:convert_www_form_vars,src_cp932,"cp932","cp932")

    assert_equal(dst_utf8_to_utf8.class,Hash)
    assert_equal(dst_utf8_to_cp932.class,Hash)
    assert_equal(dst_cp932_to_utf8.class,Hash)
    assert_equal(dst_cp932_to_cp932.class,Hash)

    assert_equal(dst_utf8_to_utf8["val_from"],"東京".encode("utf-8"))
    assert_equal(dst_cp932_to_utf8["val_from"],"東京".encode("utf-8"))
    assert_equal(dst_utf8_to_cp932["val_from"],"東京".encode("cp932"))
    assert_equal(dst_cp932_to_cp932["val_from"],"東京".encode("cp932"))

    assert_equal(dst_utf8_to_utf8["val_to"],"大宮(埼玉県)".encode("utf-8"))
    assert_equal(dst_cp932_to_utf8["val_to"],"大宮(埼玉県)".encode("utf-8"))
    assert_equal(dst_utf8_to_cp932["val_to"],"大宮(埼玉県)".encode("cp932"))
    assert_equal(dst_cp932_to_cp932["val_to"],"大宮(埼玉県)".encode("cp932"))

    assert_equal(dst_utf8_to_utf8["val_htmb"],"cgi_details2")
    assert_equal(dst_cp932_to_utf8["val_htmb"],"cgi_details2")
    assert_equal(dst_utf8_to_cp932["val_htmb"],"cgi_details2")
    assert_equal(dst_cp932_to_cp932["val_htmb"],"cgi_details2")
  end

  def test_convert_jcgi_vars
    # シリアライズデータに"+","/","="が入っているバージョン
    # URIエンコードされた文字列とは違うのでテストする
    src = "val_from=東京&val_to=大宮(埼玉県)&val_htmb=cgi_details2&val_serialize_data=SHlUczAxLjAwLjAzrAQAAAAAygMzAQEAAgAAAAAAAAAIAAFAAAIAAAMAAAAAAAAAAgCPWAAAmFkAANVYAAAAAAAACgARAAAAAYUAAAABygMzAf//////////CgARAAAAB+UAAAADygMzAf//////////AQABAAAAAQABAAEAAAAAAA==--T322123323231:F23211121:A23121141:--336f83ce0453627150bb1723760017c20e0abc2b"
    src_utf8 = src.encode("utf-8")
    src_cp932 = src.encode("cp932")

    dst_utf8_to_utf8 = @helper_output_common.__send__(:convert_jcgi_vars,src_utf8,"utf-8")
    dst_utf8_to_cp932 = @helper_output_common.__send__(:convert_jcgi_vars,src_utf8,"cp932")
    dst_cp932_to_utf8 = @helper_output_common.__send__(:convert_jcgi_vars,src_cp932,"utf-8")
    dst_cp932_to_cp932 = @helper_output_common.__send__(:convert_jcgi_vars,src_cp932,"cp932")

    assert_equal(dst_utf8_to_utf8["val_from"],"東京".encode("utf-8"))
    assert_equal(dst_cp932_to_utf8["val_from"],"東京".encode("utf-8"))
    assert_equal(dst_utf8_to_cp932["val_from"],"東京".encode("cp932"))
    assert_equal(dst_cp932_to_cp932["val_from"],"東京".encode("cp932"))

    assert_equal(dst_utf8_to_utf8["val_to"],"大宮(埼玉県)".encode("utf-8"))
    assert_equal(dst_cp932_to_utf8["val_to"],"大宮(埼玉県)".encode("utf-8"))
    assert_equal(dst_utf8_to_cp932["val_to"],"大宮(埼玉県)".encode("cp932"))
    assert_equal(dst_cp932_to_cp932["val_to"],"大宮(埼玉県)".encode("cp932"))

    assert_equal(dst_utf8_to_utf8["val_htmb"],"cgi_details2")
    assert_equal(dst_cp932_to_utf8["val_htmb"],"cgi_details2")
    assert_equal(dst_utf8_to_cp932["val_htmb"],"cgi_details2")
    assert_equal(dst_cp932_to_cp932["val_htmb"],"cgi_details2")

    assert_equal(dst_utf8_to_utf8["val_serialize_data"],"SHlUczAxLjAwLjAzrAQAAAAAygMzAQEAAgAAAAAAAAAIAAFAAAIAAAMAAAAAAAAAAgCPWAAAmFkAANVYAAAAAAAACgARAAAAAYUAAAABygMzAf//////////CgARAAAAB+UAAAADygMzAf//////////AQABAAAAAQABAAEAAAAAAA==--T322123323231:F23211121:A23121141:--336f83ce0453627150bb1723760017c20e0abc2b")
    assert_equal(dst_cp932_to_utf8["val_serialize_data"],"SHlUczAxLjAwLjAzrAQAAAAAygMzAQEAAgAAAAAAAAAIAAFAAAIAAAMAAAAAAAAAAgCPWAAAmFkAANVYAAAAAAAACgARAAAAAYUAAAABygMzAf//////////CgARAAAAB+UAAAADygMzAf//////////AQABAAAAAQABAAEAAAAAAA==--T322123323231:F23211121:A23121141:--336f83ce0453627150bb1723760017c20e0abc2b")
    assert_equal(dst_utf8_to_cp932["val_serialize_data"],"SHlUczAxLjAwLjAzrAQAAAAAygMzAQEAAgAAAAAAAAAIAAFAAAIAAAMAAAAAAAAAAgCPWAAAmFkAANVYAAAAAAAACgARAAAAAYUAAAABygMzAf//////////CgARAAAAB+UAAAADygMzAf//////////AQABAAAAAQABAAEAAAAAAA==--T322123323231:F23211121:A23121141:--336f83ce0453627150bb1723760017c20e0abc2b")
    assert_equal(dst_cp932_to_cp932["val_serialize_data"],"SHlUczAxLjAwLjAzrAQAAAAAygMzAQEAAgAAAAAAAAAIAAFAAAIAAAMAAAAAAAAAAgCPWAAAmFkAANVYAAAAAAAACgARAAAAAYUAAAABygMzAf//////////CgARAAAAB+UAAAADygMzAf//////////AQABAAAAAQABAAEAAAAAAA==--T322123323231:F23211121:A23121141:--336f83ce0453627150bb1723760017c20e0abc2b")
  end
end
