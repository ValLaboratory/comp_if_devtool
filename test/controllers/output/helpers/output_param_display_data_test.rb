# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "yaml"
require "controllers/output/helpers/output_param_display_data"
require "models/models"

YAML::ENGINE.yamler = "psych"

class HelperOutputParamDisplayData < Test::Unit::TestCase
  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_DATA = File.join(TEST_DIR,"../test_data")
  TEST_ROOT = File.join(TEST_DIR,"../../..")

  # moduleテスト用のダミークラス
  class HelperOutputParamDisplayDataDummy
    include V2apiDevTool::Controller::Helper::OutputParamDisplayData
  end

  def setup
    @helper_output_param_display_data = HelperOutputParamDisplayDataDummy.new

    # パラメータ表示順データのロード用
    view_data_expand_path = File.join(TEST_ROOT,"data/view")
    @view_data = V2apiDevTool::Model::ViewData.new(view_data_expand_path)

    # APIデータのロード用
    api_data_expand_path = File.join(TEST_ROOT,"data/api")
    @api_data = V2apiDevTool::Model::ApiData.new(api_data_expand_path)
  end




  def test_add_static_count
    static_counts_empty = {}
    static_counts_1_count = {"routeNo" => "1"}


    add_count_name_route_no = "routeNo"
    add_count_name_line_no = "lineNo"


    add_count_number = "1"


    result_new_counts_1_count = {"routeNo" => "1"}
    result_new_counts_2_counts = {"routeNo" => "1", "lineNo" => "1"}


    new_counts_1_count = nil
    new_counts_2_counts = nil
    assert_nothing_raised do
      new_counts_1_count = 
        @helper_output_param_display_data.__send__(:add_static_count,
                                                   static_counts_empty,
                                                   add_count_name_route_no,
                                                   add_count_number)
      new_counts_2_counts = 
        @helper_output_param_display_data.__send__(:add_static_count,
                                                   static_counts_1_count,
                                                   add_count_name_line_no,
                                                   add_count_number)
    end
    assert_equal(result_new_counts_1_count,new_counts_1_count)
    assert_equal(result_new_counts_2_counts,new_counts_2_counts)
  end




  def test_replace_counts
    param_name_1_count = "val_route_[routeNo]"
    param_name_2_counts = "val_r[routeNo]_line_name_[lineNo]"
    param_name_not_replaced_all_counts = "val_r[routeNo]_csect[csectNo1]_[csectNo2]"


    counts_with_value_1_count = {"routeNo" => "1"}
    counts_with_value_2_counts = {"routeNo" => "1", "lineNo" => "2"}


    result_replaced_name_1_count = "val_route_1"
    result_replaced_name_2_counts = "val_r1_line_name_2"
    result_replaced_name_not_replaced_all_counts = "val_r1_csect[csectNo1]_[csectNo2]"


    replaced_name_1_count = nil
    replaced_name_2_counts = nil
    replaced_name_not_replaced_all_counts = nil
    assert_nothing_raised do
      replaced_name_1_count = 
        @helper_output_param_display_data.__send__(:replace_counts,
                                                   param_name_1_count,
                                                   counts_with_value_1_count)
      replaced_name_2_counts = 
        @helper_output_param_display_data.__send__(:replace_counts,
                                                   param_name_2_counts,
                                                   counts_with_value_2_counts)
      replaced_name_not_replaced_all_counts = 
        @helper_output_param_display_data.__send__(:replace_counts,
                                                   param_name_not_replaced_all_counts,
                                                   counts_with_value_1_count)
    end
    assert_equal(result_replaced_name_1_count,replaced_name_1_count)
    assert_equal(result_replaced_name_2_counts,replaced_name_2_counts)
    assert_equal(result_replaced_name_not_replaced_all_counts,replaced_name_not_replaced_all_counts)
  end




  def test_get_param_names_from_response
    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    response = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))


    # ================ param_name_base定義 ================
    param_name_base_standard = "val_route_1"
    param_name_base_have_counts = "val_r1_csect[csectNo1]_[csectNo2]"


    # ================ 戻り値定義 ================
    result_param_names_standard = ["val_route_1"]
    result_param_names_have_counts = ["val_r1_csect1_3","val_r1_csect5_7"]


    # ================ テスト実行 ================
    param_names_standard = nil
    param_names_have_counts = nil
    assert_nothing_raised do
      param_names_standard = 
        @helper_output_param_display_data.__send__(:get_param_names_from_response,
                                                   param_name_base_standard,
                                                   response)
      param_names_have_counts = 
        @helper_output_param_display_data.__send__(:get_param_names_from_response,
                                                   param_name_base_have_counts,
                                                   response)
    end
    assert_equal(result_param_names_standard.sort,param_names_standard.sort)
    assert_equal(result_param_names_have_counts.sort,param_names_have_counts.sort)
  end




  def test_get_display_children_data
    # ================ パラメータデータ定義 ================
    params_def_data = @api_data.load_output_params("cgi_details2")


    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    response = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))


    # ================ orderデータ定義 ================
    # countGroupNumberComment要素がある場合
    order_param_yaml_has_group_number_comment = <<ORDER_PARAM
name: val_route_cnt
numberOf: routeNo
countGroupComment: 経路
countGroupNumberComment: 経路
children:
- name: val_route_[routeNo]
- name: val_r[routeNo]_csect[csectNo1]_[csectNo2]
ORDER_PARAM

    # countGroupNumberComment要素がない場合
    order_param_yaml_no_group_number_comment = <<ORDER_PARAM
name: val_route_cnt
numberOf: routeNo
countGroupComment: 経路
children:
- name: val_route_[routeNo]
- name: val_r[routeNo]_csect[csectNo1]_[csectNo2]
ORDER_PARAM

    # 置換される変数部分が2つの場合
    order_param_yaml_have_2_counts = <<ORDER_PARAM
name: val_r[routeNo]_fsect_cnt
numberOf: fsectNo
countGroupComment: 乗車券区間
countGroupNumberComment: 乗車券区間
children:
- name: val_r[routeNo]_fsect_from_[fsectNo]
- name: val_r[routeNo]_fsect_to_[fsectNo]
ORDER_PARAM

    # 型エラー
    order_param_yaml_error_class = <<ORDER_PARAMS
- "Hashじゃない"
ORDER_PARAMS

    # children要素がない
    order_param_yaml_error_no_children = <<ORDER_PARAM
name: val_route_[routeNo]
numberOf: routeNo
ORDER_PARAM

    # numberOf要素がない
    order_param_yaml_error_no_number_of = <<ORDER_PARAM
name: val_route_[routeNo]
children:
- name: val_route_[routeNo]
- name: val_r[routeNo]_csect[csectNo1]_[csectNo2]
ORDER_PARAM

    order_param_data_has_group_number_comment = YAML::load(order_param_yaml_has_group_number_comment)
    order_param_data_no_group_number_comment = YAML::load(order_param_yaml_no_group_number_comment)
    order_param_data_have_2_counts = YAML::load(order_param_yaml_have_2_counts)
    order_param_data_error_class = YAML::load(order_param_yaml_error_class)
    order_param_data_error_no_children = YAML::load(order_param_yaml_error_no_children)
    order_param_data_error_no_number_of = YAML::load(order_param_yaml_error_no_number_of)


    # ================ static_counts定義 ================
    # 何もない場合(変数部分が1つの場合に使用)
    static_counts_empty = {}
    # routeNo=1の場合(変数部分が2つの場合に使用)
    static_counts_routeno = {"routeNo" => 1}


    # ================ 結果データ定義 ================
    result_yaml_has_group_number_comment = <<RESULT
- countGroupNumberComment: 経路1
  params:
  - comment: 経路の文字列
    name: val_route_1
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r1_csect1_3
    responseValue: '1'
  - comment: 乗継割引相対組み合わせ連番
    name: val_r1_csect5_7
    responseValue: '2'
- countGroupNumberComment: 経路2
  params:
  - comment: 経路の文字列
    name: val_route_2
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急はくたか－越後湯沢－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r2_csect1_3
    responseValue: '1'
  - comment: 乗継割引相対組み合わせ連番
    name: val_r2_csect5_7
    responseValue: '2'
- countGroupNumberComment: 経路3
  params:
  - comment: 経路の文字列
    name: val_route_3
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－燕三条－ＪＲ弥彦線－東三条－ＪＲ特急北越－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r3_csect1_3
    responseValue: '1'
RESULT

    result_yaml_no_group_number_comment = <<RESULT
- params:
  - comment: 経路の文字列
    name: val_route_1
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r1_csect1_3
    responseValue: '1'
  - comment: 乗継割引相対組み合わせ連番
    name: val_r1_csect5_7
    responseValue: '2'
- params:
  - comment: 経路の文字列
    name: val_route_2
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急はくたか－越後湯沢－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r2_csect1_3
    responseValue: '1'
  - comment: 乗継割引相対組み合わせ連番
    name: val_r2_csect5_7
    responseValue: '2'
- params:
  - comment: 経路の文字列
    name: val_route_3
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－燕三条－ＪＲ弥彦線－東三条－ＪＲ特急北越－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r3_csect1_3
    responseValue: '1'
RESULT

    result_yaml_have_2_counts = <<RESULT
- countGroupNumberComment: 乗車券区間1
  params:
  - comment: 乗車券区間の開始路線
    name: val_r1_fsect_from_1
    responseValue: '1'
  - comment: 乗車券区間の終了路線
    name: val_r1_fsect_to_1
    responseValue: '7'
RESULT

    result_data_has_group_number_comment = YAML::load(result_yaml_has_group_number_comment)
    result_data_no_group_number_comment = YAML::load(result_yaml_no_group_number_comment)
    result_data_have_2_counts = YAML::load(result_yaml_have_2_counts)

    # ================ 結果パラメータ名リスト定義 ================
    # パラメータ名の配列の定義
    result_param_names_has_1_count = 
      ["val_route_1","val_route_2","val_route_3","val_r1_csect1_3","val_r1_csect5_7","val_r2_csect1_3","val_r2_csect5_7","val_r3_csect1_3"]
    result_param_names_have_2_counts = 
      ["val_r1_fsect_from_1","val_r1_fsect_to_1"]


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_children_data,
                                                 params_def_data,
                                                 order_param_data_error_class,
                                                 response,
                                                 3,
                                                 static_counts_empty)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_children_data,
                                                 params_def_data,
                                                 order_param_data_error_no_children,
                                                 response,
                                                 3,
                                                 static_counts_empty)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_children_data,
                                                 params_def_data,
                                                 order_param_data_error_no_number_of,
                                                 response,
                                                 3,
                                                 static_counts_empty)
    end
    # max_countがIntegerでない場合
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_children_data,
                                                 params_def_data,
                                                 order_param_data_has_group_number_comment,
                                                 response,
                                                 "3",
                                                 static_counts_empty)
    end

    display_param_data_has_group_number_comment = nil
    display_param_data_no_group_number_comment = nil
    display_param_data_have_2_counts = nil
    display_param_names_has_group_number_comment = nil
    display_param_names_no_group_number_comment = nil
    display_param_names_have_2_counts = nil
    assert_nothing_raised do
      display_param_data_has_group_number_comment, display_param_names_has_group_number_comment = 
        @helper_output_param_display_data.__send__(:get_display_children_data,
                                                   params_def_data,
                                                   order_param_data_has_group_number_comment,
                                                   response,
                                                   3,
                                                   static_counts_empty)
      display_param_data_no_group_number_comment, display_param_names_no_group_number_comment = 
        @helper_output_param_display_data.__send__(:get_display_children_data,
                                                   params_def_data,
                                                   order_param_data_no_group_number_comment,
                                                   response,
                                                   3,
                                                   static_counts_empty)
      display_param_data_have_2_counts, display_param_names_have_2_counts = 
        @helper_output_param_display_data.__send__(:get_display_children_data,
                                                   params_def_data,
                                                   order_param_data_have_2_counts,
                                                   response,
                                                   1,
                                                   static_counts_routeno)
    end
    assert_equal(result_data_has_group_number_comment,display_param_data_has_group_number_comment)
    assert_equal(result_data_no_group_number_comment,display_param_data_no_group_number_comment)
    assert_equal(result_data_have_2_counts,display_param_data_have_2_counts)
    assert_equal(result_param_names_has_1_count.sort,display_param_names_has_group_number_comment.sort)  # 順番を一致させるためにソート
    assert_equal(result_param_names_has_1_count.sort,display_param_names_no_group_number_comment.sort)  # 順番を一致させるためにソート
    assert_equal(result_param_names_have_2_counts.sort,display_param_names_have_2_counts.sort)  # 順番を一致させるためにソート
  end




  def test_get_display_param_data
    # ================ パラメータデータ定義 ================
    params_def_data = @api_data.load_output_params("cgi_details2")


    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    response = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))


    # ================ orderデータ定義 ================
    # children要素がある場合
    order_param_yaml_has_children = <<ORDER_PARAM
name: val_route_cnt
numberOf: routeNo
countGroupComment: 経路
countGroupNumberComment: 経路
children:
- name: val_route_[routeNo]
- name: val_r[routeNo]_csect[csectNo1]_[csectNo2]
ORDER_PARAM

    # children要素がない + 変数名部分がある
    order_param_yaml_no_children = <<ORDER_PARAM
name: val_route_[routeNo]
ORDER_PARAM

    # 型エラー
    order_param_yaml_error_class = <<ORDER_PARAMS
- "Hashじゃない"
ORDER_PARAMS

    # name要素がない
    order_param_yaml_error_no_name = <<ORDER_PARAM
numberOf: routeNo
ORDER_PARAM

    order_param_data_has_children = YAML::load(order_param_yaml_has_children)
    order_param_data_no_children = YAML::load(order_param_yaml_no_children)
    order_param_data_error_class = YAML::load(order_param_yaml_error_class)
    order_param_data_error_no_name = YAML::load(order_param_yaml_error_no_name)


    # ================ static_counts定義 ================
    static_counts = {}


    # ================ 結果データ定義 ================
    result_yaml_has_children = <<RESULT
countGroupComment: 経路
comment: 経路の数
name: val_route_cnt
responseValue: '3'
children:
- countGroupNumberComment: 経路1
  params:
  - comment: 経路の文字列
    name: val_route_1
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r1_csect1_3
    responseValue: '1'
  - comment: 乗継割引相対組み合わせ連番
    name: val_r1_csect5_7
    responseValue: '2'
- countGroupNumberComment: 経路2
  params:
  - comment: 経路の文字列
    name: val_route_2
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急はくたか－越後湯沢－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r2_csect1_3
    responseValue: '1'
  - comment: 乗継割引相対組み合わせ連番
    name: val_r2_csect5_7
    responseValue: '2'
- countGroupNumberComment: 経路3
  params:
  - comment: 経路の文字列
    name: val_route_3
    responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－燕三条－ＪＲ弥彦線－東三条－ＪＲ特急北越－新潟－ＪＲ特急いなほ－村上(新潟県)
  - comment: 乗継割引相対組み合わせ連番
    name: val_r3_csect1_3
    responseValue: '1'
RESULT

    result_yaml_no_children = <<RESULT
comment: 経路の文字列
name: val_route_1
responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
RESULT

    result_data_has_children = YAML::load(result_yaml_has_children)
    result_data_no_children = YAML::load(result_yaml_no_children)


    # ================ 結果パラメータ名リスト定義 ================
    # パラメータ名の配列の定義
    result_param_names_has_children = 
      ["val_route_cnt","val_route_1","val_route_2","val_route_3","val_r1_csect1_3","val_r1_csect5_7","val_r2_csect1_3","val_r2_csect5_7","val_r3_csect1_3"]
    result_param_names_no_children = 
      ["val_route_1"]


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_param_data,
                                                 params_def_data,
                                                 order_param_data_error_class,
                                                 response,
                                                 "val_route_cnt",
                                                 static_counts)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_param_data,
                                                 params_def_data,
                                                 order_param_data_error_no_name,
                                                 response,
                                                 "val_route_cnt",
                                                 static_counts)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_param_data,
                                                 params_def_data,
                                                 order_param_data_has_children,
                                                 response,
                                                 1,
                                                 static_counts)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_param_data,
                                                 params_def_data,
                                                 order_param_data_has_children,
                                                 response,
                                                 "val_version",
                                                 static_counts)
    end

    display_param_data_has_children = nil
    display_param_data_no_children = nil
    display_param_names_has_children = nil
    display_param_names_no_children = nil
    assert_nothing_raised do
      display_param_data_has_children, display_param_names_has_children = 
        @helper_output_param_display_data.__send__(:get_display_param_data,
                                                   params_def_data,
                                                   order_param_data_has_children,
                                                   response,
                                                   "val_route_cnt",
                                                   static_counts)
      display_param_data_no_children, display_param_names_no_children = 
        @helper_output_param_display_data.__send__(:get_display_param_data,
                                                   params_def_data,
                                                   order_param_data_no_children,
                                                   response,
                                                   "val_route_1",
                                                   static_counts)
    end
    assert_equal(result_data_has_children,display_param_data_has_children)
    assert_equal(result_data_no_children,display_param_data_no_children)
    assert_equal(result_param_names_has_children.sort,display_param_names_has_children.sort)  # 順番を一致させるためにソート
    assert_equal(result_param_names_no_children.sort,display_param_names_no_children.sort)  # 順番を一致させるためにソート
  end



  #
  # get_display_params_dataのテスト
  # (再帰している場合 + static_countsのエラーチェック)
  #
  def test_get_display_params_data_has_static_counts
    # ================ パラメータデータ定義 ================
    params_def_data = @api_data.load_output_params("cgi_details2")


    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    response = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))


    # ================ orderデータ定義 ================
    # パラメータが存在する一般的なorderデータの場合(childrenの中身)
    order_params_yaml_standard = <<ORDER_GROUP
- name: val_route_[routeNo]
- name: val_r[routeNo]_csect[csectNo1]_[csectNo2]
ORDER_GROUP

    order_params_data_standard = YAML::load(order_params_yaml_standard)


    # ================ static_counts定義 ================
    # routeNo=1の場合
    static_counts_standard = {"routeNo" => 1}
    # 不正値
    static_counts_error = ["Hashじゃない"]


    # ================ 結果データ定義 ================
    result_yaml_standard = <<RESULT
- comment: 経路の文字列
  name: val_route_1
  responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
- comment: 乗継割引相対組み合わせ連番
  name: val_r1_csect1_3
  responseValue: '1'
- comment: 乗継割引相対組み合わせ連番
  name: val_r1_csect5_7
  responseValue: '2'
RESULT

    result_data_standard = YAML::load(result_yaml_standard)


    # ================ 結果パラメータ名リスト定義 ================
    # パラメータ名の配列の定義
    result_param_names_standard = 
      ["val_route_1","val_r1_csect1_3","val_r1_csect5_7"]


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_params_data,
                                                 params_def_data,
                                                 order_params_data_standard,
                                                 response,
                                                 static_counts_error)
    end

    display_params_data_standard = nil
    display_param_names_standard = nil
    assert_nothing_raised do
      display_params_data_standard, display_param_names_standard = 
        @helper_output_param_display_data.__send__(:get_display_params_data,
                                                   params_def_data,
                                                   order_params_data_standard,
                                                   response,
                                                   static_counts_standard)
    end
    assert_equal(result_data_standard,display_params_data_standard)
    assert_equal(result_param_names_standard.sort,display_param_names_standard.sort)  # 順番を一致させるためにソート
  end




  #
  # get_display_params_dataのテスト
  # (再帰されていない最初の呼び出しの場合 + order_params_dataのエラーチェック)
  #
  def test_get_display_params_data_no_static_counts
    # ================ パラメータデータ定義 ================
    params_def_data = @api_data.load_output_params("cgi_details2")


    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    response = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))


    # ================ orderデータ定義 ================
    # パラメータが存在する一般的なorderデータの場合
    order_params_yaml_standard = <<ORDER_PARAMS
- name: val_route_cnt
  numberOf: routeNo
  countGroupComment: 経路
  countGroupNumberComment: 経路
  children:
  - name: val_route_[routeNo]
  - name: val_r[routeNo]_csect[csectNo1]_[csectNo2]
- name: val_reuse_jr2sectteiki
ORDER_PARAMS

    # 存在するパラメータが1つも無い場合
    order_params_yaml_not_exist_params = <<ORDER_PARAMS
- name: val_version
- name: val_jrtrain_timetable_version
ORDER_PARAMS

    # 型エラー
    order_params_yaml_error_class = <<ORDER_PARAMS
name: "Arrayじゃない"
ORDER_PARAMS

    order_params_data_standard = YAML::load(order_params_yaml_standard)
    order_params_data_not_exist_params = YAML::load(order_params_yaml_not_exist_params)
    order_params_data_error_class = YAML::load(order_params_yaml_error_class)


    # ================ 結果データ定義 ================
    result_yaml_standard = <<RESULT
- countGroupComment: 経路
  comment: 経路の数
  name: val_route_cnt
  responseValue: '3'
  children:
  - countGroupNumberComment: 経路1
    params:
    - comment: 経路の文字列
      name: val_route_1
      responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
    - comment: 乗継割引相対組み合わせ連番
      name: val_r1_csect1_3
      responseValue: '1'
    - comment: 乗継割引相対組み合わせ連番
      name: val_r1_csect5_7
      responseValue: '2'
  - countGroupNumberComment: 経路2
    params:
    - comment: 経路の文字列
      name: val_route_2
      responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急はくたか－越後湯沢－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
    - comment: 乗継割引相対組み合わせ連番
      name: val_r2_csect1_3
      responseValue: '1'
    - comment: 乗継割引相対組み合わせ連番
      name: val_r2_csect5_7
      responseValue: '2'
  - countGroupNumberComment: 経路3
    params:
    - comment: 経路の文字列
      name: val_route_3
      responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－燕三条－ＪＲ弥彦線－東三条－ＪＲ特急北越－新潟－ＪＲ特急いなほ－村上(新潟県)
    - comment: 乗継割引相対組み合わせ連番
      name: val_r3_csect1_3
      responseValue: '1'
- comment: val_jr2sectteikiに入力した内容を出力
  name: val_reuse_jr2sectteiki
  responseValue: '0'
RESULT

    result_data_standard = YAML::load(result_yaml_standard)
    result_data_not_include_apis = []


    # ================ 結果パラメータ名リスト定義 ================
    # パラメータ名の配列の定義
    result_param_names_standard = 
      ["val_route_cnt","val_route_1","val_route_2","val_route_3","val_r1_csect1_3","val_r1_csect5_7","val_r2_csect1_3","val_r2_csect5_7","val_r3_csect1_3","val_reuse_jr2sectteiki"]
    result_param_names_not_exist_params = []


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_params_data,
                                                 params_def_data,
                                                 order_params_data_error_class,
                                                 response)
    end

    display_params_data_standard = nil
    display_params_data_not_exist_params = nil
    display_param_names_standard = nil
    display_param_names_not_exist_params = nil
    assert_nothing_raised do
      display_params_data_standard, display_param_names_standard = 
        @helper_output_param_display_data.__send__(:get_display_params_data,
                                                   params_def_data,
                                                   order_params_data_standard,
                                                   response)
      display_params_data_not_exist_params, display_param_names_not_exist_params = 
        @helper_output_param_display_data.__send__(:get_display_params_data,
                                                   params_def_data,
                                                   order_params_data_not_exist_params,
                                                   response)
    end
    assert_equal(result_data_standard,display_params_data_standard)
    assert_equal(result_data_not_include_apis,display_params_data_not_exist_params)
    assert_equal(result_param_names_standard.sort,display_param_names_standard.sort)  # 順番を一致させるためにソート
    assert_equal(result_param_names_not_exist_params.sort,display_param_names_not_exist_params.sort)  # 順番を一致させるためにソート
  end







  def test_get_display_group_data
    # ================ パラメータデータ定義 ================
    params_def_data = @api_data.load_output_params("cgi_details2")


    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    response = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))


    # ================ orderデータ定義 ================
    # パラメータが存在する一般的なorderデータの場合
    order_group_yaml_standard = <<ORDER_GROUP
apis:
- cgi_details2
- jcgi_details2
params:
- name: val_route_cnt
  numberOf: routeNo
  countGroupComment: 経路
  countGroupNumberComment: 経路
  children:
  - name: val_route_[routeNo]
  - name: val_r[routeNo]_csect[csectNo1]_[csectNo2]
- name: val_reuse_jr2sectteiki
ORDER_GROUP

    # APIの名前が含まれない場合
    order_group_yaml_not_include_apis = <<ORDER_GROUP
apis:
- jcgi_details2
params:
- name: val_route_cnt
  numberOf: routeNo
  countGroupComment: 経路
  countGroupNumberComment: 経路
  children:
  - name: val_route_[routeNo]
ORDER_GROUP

    # 型エラー
    order_group_yaml_error_class = <<ORDER_GROUP
- "Hashじゃない"
ORDER_GROUP

    # apis要素がない
    order_group_yaml_error_no_apis = <<ORDER_GROUP
params:
- name: val_route_cnt
ORDER_GROUP

    # apis要素がない
    order_group_yaml_error_no_params = <<ORDER_GROUP
apis:
- cgi_details2
- jcgi_details2
ORDER_GROUP

    order_group_data_standard = YAML::load(order_group_yaml_standard)
    order_group_data_not_include_apis = YAML::load(order_group_yaml_not_include_apis)
    order_group_data_error_class = YAML::load(order_group_yaml_error_class)
    order_group_data_not_error_no_apis = YAML::load(order_group_yaml_error_no_apis)
    order_group_data_not_error_no_params = YAML::load(order_group_yaml_error_no_params)


    # ================ 結果データ定義 ================
    result_yaml_standard = <<RESULT
params:
- countGroupComment: 経路
  comment: 経路の数
  name: val_route_cnt
  responseValue: '3'
  children:
  - countGroupNumberComment: 経路1
    params:
    - comment: 経路の文字列
      name: val_route_1
      responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
    - comment: 乗継割引相対組み合わせ連番
      name: val_r1_csect1_3
      responseValue: '1'
    - comment: 乗継割引相対組み合わせ連番
      name: val_r1_csect5_7
      responseValue: '2'
  - countGroupNumberComment: 経路2
    params:
    - comment: 経路の文字列
      name: val_route_2
      responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急はくたか－越後湯沢－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
    - comment: 乗継割引相対組み合わせ連番
      name: val_r2_csect1_3
      responseValue: '1'
    - comment: 乗継割引相対組み合わせ連番
      name: val_r2_csect5_7
      responseValue: '2'
  - countGroupNumberComment: 経路3
    params:
    - comment: 経路の文字列
      name: val_route_3
      responseValue: 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－燕三条－ＪＲ弥彦線－東三条－ＪＲ特急北越－新潟－ＪＲ特急いなほ－村上(新潟県)
    - comment: 乗継割引相対組み合わせ連番
      name: val_r3_csect1_3
      responseValue: '1'
- comment: val_jr2sectteikiに入力した内容を出力
  name: val_reuse_jr2sectteiki
  responseValue: '0'
RESULT

    result_data_standard = YAML::load(result_yaml_standard)
    result_data_not_include_apis = {}


    # ================ 結果パラメータ名リスト定義 ================
    # パラメータ名の配列の定義
    result_param_names_standard = 
      ["val_route_cnt","val_route_1","val_route_2","val_route_3","val_r1_csect1_3","val_r1_csect5_7","val_r2_csect1_3","val_r2_csect5_7","val_r3_csect1_3","val_reuse_jr2sectteiki"]
    result_param_names_not_include_apis = []


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_group_data,
                                                 "cgi_details2",
                                                 params_def_data,
                                                 order_group_data_error_class,
                                                 response)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_group_data,
                                                 "cgi_details2",
                                                 params_def_data,
                                                 order_group_data_not_error_no_apis,
                                                 response)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:get_display_group_data,
                                                 "cgi_details2",
                                                 params_def_data,
                                                 order_group_data_not_error_no_params,
                                                 response)
    end

    display_group_data_standard = nil
    display_group_data_not_include_apis = nil
    display_param_names_standard = nil
    display_param_names_not_include_apis = nil
    assert_nothing_raised do
      display_group_data_standard, display_param_names_standard = 
        @helper_output_param_display_data.__send__(:get_display_group_data,
                                                   "cgi_details2",
                                                   params_def_data,
                                                   order_group_data_standard,
                                                   response)
      display_group_data_not_include_apis, display_param_names_not_include_apis = 
        @helper_output_param_display_data.__send__(:get_display_group_data,
                                                   "cgi_details2",
                                                   params_def_data,
                                                   order_group_data_not_include_apis,
                                                   response)
    end
    assert_equal(result_data_standard,display_group_data_standard)
    assert_equal(result_data_not_include_apis,display_group_data_not_include_apis)
    assert_equal(result_param_names_standard.sort,display_param_names_standard.sort)  # 順番を一致させるためにソート
    assert_equal(result_param_names_not_include_apis.sort,display_param_names_not_include_apis.sort)  # 順番を一致させるためにソート
  end




  def test_get_defined_params_display_data
    # ================ orderデータ定義 ================
    order_data = @view_data.load_output_order
    # 不正値
    order_yaml_error = <<ORDER_ERROR
---
name: val_route_cnt
numberOf: routeNo
countGroupComment: 経路
countGroupNumberComment: 経路
children:
- name: val_route_[routeNo]
ORDER_ERROR

    order_data_error = YAML::load(order_yaml_error)


    # ================ パラメータデータ定義 ================
    params_def_data = @api_data.load_output_params("cgi_details2")
    # 不正値
    params_def_data_error = ["Hashじゃない"]


    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    response = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))
    # 不正値
    response_error = ["Hashじゃない"]


    # ================ 結果データ定義 ================
    # ひたすら長いので"display_data_sample_cgi_details2.yml"を参照
    # ファイルの中身には最終的に渡されるデータが全て入っているので、
    # 読み込んでからdisplayParams要素のみにする
    result_data = YAML::load_file(File::join(TEST_DATA,"display_data_sample_cgi_details2.yml"))
    result_data = result_data["definedParams"]


    # ================ 結果パラメータ名リスト定義 ================
    # パラメータ名の配列の定義
    # レスポンスデータのキーから、ユーザーパラメータと未定義パラメータを
    # 除いたものを全て抽出し、配列にする
    result_param_names = response.keys
    result_param_names.delete("val_notdef_param")
    result_param_names.delete("user_param")


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:generate_display_data,
                                                 "cgi_details2",
                                                 params_def_data,
                                                 order_data_error,
                                                 response)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:generate_display_data,
                                                 "cgi_details2",
                                                 params_def_data_error,
                                                 order_data,
                                                 response)
    end
    assert_raise(ArgumentError) do
      @helper_output_param_display_data.__send__(:generate_display_data,
                                                 "cgi_details2",
                                                 params_def_data,
                                                 order_data,
                                                 response_error)
    end

    display_defined_params_data = nil
    display_param_names = nil
    assert_nothing_raised do
      display_defined_params_data, display_param_names = 
        @helper_output_param_display_data.__send__(:get_defined_params_display_data,
                                                   "cgi_details2",
                                                   params_def_data,
                                                   order_data,
                                                   response)
    end
    assert_equal(result_data,display_defined_params_data)
    assert_equal(result_param_names.sort,display_param_names.sort)  # 順番を一致させるためにソート
  end




  def test_get_route_string_data
    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    response_cgi_details2 = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))
    # 長いので"response_sample_cgi_result2_h.yml"を参照
    response_cgi_result2_h = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_result2_h.yml"))
    # 長くもないけど"response_sample_cgi_station.yml"を参照
    response_cgi_station = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_station.yml"))


    # ================ 結果データ定義 ================
    result_yaml_route_string_array = <<RESULT
- 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
- 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急はくたか－越後湯沢－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)
- 出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－燕三条－ＪＲ弥彦線－東三条－ＪＲ特急北越－新潟－ＪＲ特急いなほ－村上(新潟県)
RESULT

    result_data_route_string_array = YAML::load(result_yaml_route_string_array)
    result_data_route_string_string = 
      "出雲市－ＪＲ特急やくも－岡山－ＪＲ新幹線のぞみ－名古屋－ＪＲ特急しなの－長野－ＪＲ妙高－直江津－ＪＲ特急北越－長岡－ＪＲ新幹線とき－新潟－ＪＲ特急いなほ－村上(新潟県)"


    # ================ テスト実行 ================
    display_route_string_data_cgi_details2 = nil
    display_route_string_data_cgi_result2_h = nil
    display_route_string_data_cgi_station = nil
    assert_nothing_raised do
      display_route_string_data_cgi_details2 = 
        @helper_output_param_display_data.__send__(:get_route_string_data,
                                                   response_cgi_details2)
      display_route_string_data_cgi_result2_h = 
        @helper_output_param_display_data.__send__(:get_route_string_data,
                                                   response_cgi_result2_h)
      display_route_string_data_cgi_station = 
        @helper_output_param_display_data.__send__(:get_route_string_data,
                                                   response_cgi_station)
    end
    assert_equal(result_data_route_string_array,display_route_string_data_cgi_details2)
    assert_equal(result_data_route_string_string,display_route_string_data_cgi_result2_h)
    assert_equal(nil,display_route_string_data_cgi_station)
  end




  def test_get_user_params_data
    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # ユーザーパラメータ使用データ
    response_cgi_details2 = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))
    # 長くもないけど"response_sample_cgi_station.yml"を参照
    # ユーザーパラメータ未使用データ
    response_cgi_station = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_station.yml"))


    # ================ 結果データ定義 ================
    result_yaml_has_user_params = <<RESULT
- name: user_param
  responseValue: nisikokubunji
RESULT

    result_data_has_user_params = YAML::load(result_yaml_has_user_params)
    result_data_no_user_params = []


    # ================ 結果パラメータ名リスト定義 ================
    result_param_names_has_user_params = ["user_param"]
    result_param_names_no_user_params = []


    # ================ テスト実行 ================
    display_user_params_data_has_user_params = nil
    display_user_params_data_no_user_params = nil
    display_param_names_has_user_params = nil
    display_param_names_no_user_params = nil
    assert_nothing_raised do
      display_user_params_data_has_user_params, display_param_names_has_user_params = 
        @helper_output_param_display_data.__send__(:get_user_params_data,
                                                   response_cgi_details2)
      display_user_params_data_no_user_params, display_param_names_no_user_params = 
        @helper_output_param_display_data.__send__(:get_user_params_data,
                                                   response_cgi_station)
    end
    assert_equal(result_data_has_user_params,display_user_params_data_has_user_params)
    assert_equal(result_data_no_user_params,display_user_params_data_no_user_params)
    assert_equal(result_param_names_has_user_params.sort,display_param_names_has_user_params.sort)  # 順番を一致させるためにソート
    assert_equal(result_param_names_no_user_params.sort,display_param_names_no_user_params.sort)  # 順番を一致させるためにソート
  end




  def test_get_not_defined_params_display_data
    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 未定義パラメータを含むデータ
    response_cgi_details2 = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))
    # 長くもないけど"response_sample_cgi_station.yml"を参照
    # 未定義パラメータを含まないデータ
    response_cgi_station = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_station.yml"))


    # ================ 定義済みパラメータリスト定義 ================
    # レスポンスの中のval_notdef_param以外
    defined_param_names_cgi_details2 = []
    response_cgi_details2.each_key do |key|
      defined_param_names_cgi_details2 << key
    end
    defined_param_names_cgi_details2.delete("val_notdef_param")

    defined_param_names_cgi_station = ["val_stn_cnt","val_stn_name1","val_errcode","val_connect_errcode"]


    # ================ 結果データ定義 ================
    result_yaml_has_not_defined_params = <<RESULT
- name: val_notdef_param
  responseValue: invalid
RESULT

    result_data_has_not_defined_params = YAML::load(result_yaml_has_not_defined_params)
    result_data_no_not_defined_params = []


    # ================ テスト実行 ================
    display_not_defined_params_data_has_not_defined_params = nil
    display_not_defined_params_data_no_not_defined_params = nil
    assert_nothing_raised do
      display_not_defined_params_data_has_not_defined_params = 
        @helper_output_param_display_data.__send__(:get_not_defined_params_display_data,
                                                   response_cgi_details2,
                                                   defined_param_names_cgi_details2)
      display_not_defined_params_data_no_not_defined_params = 
        @helper_output_param_display_data.__send__(:get_not_defined_params_display_data,
                                                   response_cgi_station,
                                                   defined_param_names_cgi_station)
    end
    assert_equal(result_data_has_not_defined_params,display_not_defined_params_data_has_not_defined_params)
    assert_equal(result_data_no_not_defined_params,display_not_defined_params_data_no_not_defined_params)
  end




  def test_generate_display_data
    # ================ orderデータ定義 ================
    order_data = @view_data.load_output_order


    # ================ パラメータデータ定義 ================
    params_def_data_cgi_details2 = @api_data.load_output_params("cgi_details2")


    # ================ レスポンス定義 ================
    # 長いので"response_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    response_cgi_details2 = YAML::load_file(File::join(TEST_DATA,"response_sample_cgi_details2.yml"))


    # ================ 結果データ定義 ================
    # ひたすら長いので"display_data_sample_cgi_details2.yml"を参照
    # 通常のレスポンスに、ユーザーパラメータと未定義パラメータを追加している
    result_data_cgi_details2 = YAML::load_file(File::join(TEST_DATA,"display_data_sample_cgi_details2.yml"))


    # ================ テスト実行 ================
    display_data_cgi_details2 = nil
    assert_nothing_raised do
      display_data_cgi_details2 = 
        @helper_output_param_display_data.__send__(:generate_display_data,
                                                   "cgi_details2",
                                                   params_def_data_cgi_details2,
                                                   order_data,
                                                   response_cgi_details2)
    end
    assert_equal(result_data_cgi_details2,display_data_cgi_details2)
  end
end
