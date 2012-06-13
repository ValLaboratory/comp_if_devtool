# -*- coding: utf-8 -*-

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../../lib/v2apiDevTool")

gem "test-unit"
require "test/unit"
require "yaml"
require "controllers/input/helpers/input_param_display_data"
require "models/models"

YAML::ENGINE.yamler = "psych"

class HelperInputParamDisplayDataTest < Test::Unit::TestCase
  # テストのディレクトリ
  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_ROOT = File.join(TEST_DIR,"../../..")

  # moduleテスト用のダミークラス
  class HelperInputParamDisplayDataDummy
    include V2apiDevTool::Controller::Helper::InputParamDisplayData
  end

  def setup
    @helper_input_param_display_data = HelperInputParamDisplayDataDummy.new

    # パラメータ表示順データのロード用
    view_data_expand_path = File.join(TEST_ROOT,"data/view")
    @view_data = V2apiDevTool::Model::ViewData.new(view_data_expand_path)

    # APIデータのロード用
    api_data_expand_path = File.join(TEST_ROOT,"data/api")
    @api_data = V2apiDevTool::Model::ApiData.new(api_data_expand_path)
  end




  def test_get_display_param_data
    # ================ パラメータデータ定義 ================
    # エラー以外は全てcgi_details2で検証
    params_def_data_cgi_details2 = @api_data.load_input_params("cgi_details2")


    # ================ orderデータ定義 ================
    # 名称のみの場合
    order_param_yaml_standard = <<ORDER_PARAM_STANDARD
name: val_from
isStation: true
ORDER_PARAM_STANDARD

    # ref要素が存在する場合
    order_param_yaml_ref = <<ORDER_PARAM_REF
name: val_cstm1_all_type
ref: val_cstm[cstmNo]_all_type
devtoolComment: 本ツールでは1件のみ指定可
ORDER_PARAM_REF

    # 存在しないパラメータ名の場合
    order_param_yaml_not_exist = <<ORDER_PARAM_NOT_EXIST
name: val_in_name
ORDER_PARAM_NOT_EXIST

    # 型エラー
    order_param_yaml_error_class = <<ORDER_PARAM_ERROR_CLASS
- "Hashじゃない"
ORDER_PARAM_ERROR_CLASS

    # name要素がない
    order_param_yaml_error_no_name = <<ORDER_PARAM_ERROR_NO_NAME
ref: val_cstm[cstmNo]_all_type
devtoolComment: 本ツールでは1件のみ指定可
ORDER_PARAM_ERROR_NO_NAME

    order_param_data_standard = YAML::load(order_param_yaml_standard)
    order_param_data_ref = YAML::load(order_param_yaml_ref)
    order_param_data_not_exist = YAML::load(order_param_yaml_not_exist)
    order_param_data_error_class = YAML::load(order_param_yaml_error_class)
    order_param_data_error_no_name = YAML::load(order_param_yaml_error_no_name)


    # ================ 結果データ定義 ================
    result_yaml_standard = <<RESULT_STANDARD
name: val_from
isStation: true
status: required
comment: 出発駅の駅名(ロングネーム)
RESULT_STANDARD

    result_yaml_ref = <<RESULT_REF
name: val_cstm1_all_type
devtoolComment: 本ツールでは1件のみ指定可
comment: カスタマイズタイプ(全経路)
value: TeikiClassを指定
RESULT_REF

    result_data_standard = YAML::load(result_yaml_standard)
    result_data_ref = YAML::load(result_yaml_ref)
    result_data_not_exist = {}


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:get_display_param_data,
                                                params_def_data_cgi_details2,
                                                order_param_data_error_class)
    end
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:get_display_param_data,
                                                params_def_data_cgi_details2,
                                                order_param_data_error_no_name)
    end

    display_param_data_standard = nil
    display_param_data_ref = nil
    display_param_data_not_exist = nil
    assert_nothing_raised do
      display_param_data_standard = 
        @helper_input_param_display_data.__send__(:get_display_param_data,
                                                  params_def_data_cgi_details2,
                                                  order_param_data_standard)
      display_param_data_ref = 
        @helper_input_param_display_data.__send__(:get_display_param_data,
                                                  params_def_data_cgi_details2,
                                                  order_param_data_ref)
      display_param_data_not_exist = 
        @helper_input_param_display_data.__send__(:get_display_param_data,
                                                  params_def_data_cgi_details2,
                                                  order_param_data_not_exist)
    end
    assert_equal(result_data_standard,display_param_data_standard)
    assert_equal(result_data_ref,display_param_data_ref)
    assert_equal(result_data_not_exist,display_param_data_not_exist)
  end




  def test_get_display_group_data_has_group_comment
    # ================ パラメータデータ定義 ================
    # 全てcgi_details2で検証
    params_def_data_cgi_details2 = @api_data.load_input_params("cgi_details2")


    # ================ orderデータ定義 ================
    # パラメータが存在する一般的なorderデータの場合
    order_group_yaml_standard = <<ORDER_GROUP_STANDARD
groupComment: 1-1 基本入力パラメータ(平均)
apis:
- cgi_details2
- jcgi_details2
- cgi_result2
- cgi_result2_h
params:
- name: val_htmb
  inputType: system
- name: val_cgi_url
  inputType: system
- name: val_from
  isStation: true
- name: val_to
  isStation: true
- name: val_to01
  isStation: true
- name: val_to02
  isStation: true
- name: val_to03
  isStation: true
- name: val_to04
  isStation: true
ORDER_GROUP_STANDARD

    # APIの名前が含まれない場合
    order_group_yaml_not_include_apis = <<ORDER_GROUP_NOT_INCLUDE_APIS
groupComment: ダミー1
apis:
- cgi_result2
params:
- name: val_from
ORDER_GROUP_NOT_INCLUDE_APIS

    # 存在するパラメータが1つも無い場合
    order_group_yaml_not_exist_params = <<ORDER_GROUP_NOT_EXIST_PARAMS
groupComment: ダミー2
apis:
- cgi_details2
params:
- name: val_fromfrom
- name: val_toto
ORDER_GROUP_NOT_EXIST_PARAMS

    # 型エラー
    order_group_yaml_error_class = <<ORDER_GROUP_ERROR_CLASS
- "Hashじゃない"
ORDER_GROUP_ERROR_CLASS

    # apis要素がない
    order_group_yaml_error_no_apis = <<ORDER_GROUP_ERROR_NO_APIS
groupComment: エラー1
params:
- name: val_from
- name: val_to
ORDER_GROUP_ERROR_NO_APIS

    # params要素がない
    order_group_yaml_error_no_params = <<ORDER_GROUP_ERROR_NO_PARAMS
groupComment: エラー2
apis:
- jcgi_result2
ORDER_GROUP_ERROR_NO_PARAMS

    order_group_data_standard = YAML::load(order_group_yaml_standard)
    order_group_data_not_include_apis = YAML::load(order_group_yaml_not_include_apis)
    order_group_data_not_exist_params = YAML::load(order_group_yaml_not_exist_params)
    order_group_data_error_class = YAML::load(order_group_yaml_error_class)
    order_group_data_not_error_no_apis = YAML::load(order_group_yaml_error_no_apis)
    order_group_data_not_error_no_params = YAML::load(order_group_yaml_error_no_params)


    # ================ 結果データ定義 ================
    result_yaml_standard = <<RESULT_STANDARD
groupComment: 1-1 基本入力パラメータ(平均)
params:
- name: val_htmb
  inputType: system
  status: required
  comment: API名
- name: val_cgi_url
  inputType: system
  status: required
  comment: 呼び出すCGIのURL
- name: val_from
  isStation: true
  status: required
  comment: 出発駅の駅名(ロングネーム)
- name: val_to
  isStation: true
  status: cond-required
  comment: 目的駅の駅名(ロングネーム)(経由駅を指定しない場合)
- name: val_to01
  isStation: true
  status: cond-required
  comment: 経由駅または目的駅の駅名1(ロングネーム)
- name: val_to02
  isStation: true
  status: cond-required
  comment: 経由駅または目的駅の駅名2(ロングネーム)
- name: val_to03
  isStation: true
  status: cond-required
  comment: 経由駅または目的駅の駅名3(ロングネーム)
- name: val_to04
  isStation: true
  status: cond-required
  comment: 経由駅または目的駅の駅名4(ロングネーム)
RESULT_STANDARD

    result_data_standard = YAML::load(result_yaml_standard)
    result_data_not_include_apis = {}
    result_data_not_exist_params = {}


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:generate_display_data,
                                                "cgi_details2",
                                                params_def_data_cgi_details2,
                                                order_group_data_error_class)
    end
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:generate_display_data,
                                                "cgi_details2",
                                                params_def_data_cgi_details2,
                                                order_group_data_not_error_no_apis)
    end
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:generate_display_data,
                                                "cgi_details2",
                                                params_def_data_cgi_details2,
                                                order_group_data_not_error_no_params)
    end

    display_group_data_standard = nil
    display_group_data_not_include_apis = nil
    display_group_data_not_exist_params = nil
    assert_nothing_raised do
      display_group_data_standard = 
        @helper_input_param_display_data.__send__(:get_display_group_data,
                                                  "cgi_details2",
                                                  params_def_data_cgi_details2,
                                                  order_group_data_standard)
      display_group_data_not_include_apis = 
        @helper_input_param_display_data.__send__(:get_display_group_data,
                                                  "cgi_details2",
                                                  params_def_data_cgi_details2,
                                                  order_group_data_not_include_apis)
      display_group_data_not_exist_params = 
        @helper_input_param_display_data.__send__(:get_display_group_data,
                                                  "cgi_details2",
                                                  params_def_data_cgi_details2,
                                                  order_group_data_not_exist_params)
    end
    assert_equal(result_data_standard,display_group_data_standard)
    assert_equal(result_data_not_include_apis,display_group_data_not_include_apis)
    assert_equal(result_data_not_exist_params,display_group_data_not_exist_params)
  end




  def test_get_display_group_data_no_group_comment
    # ================ パラメータデータ定義 ================
    # 全てjcgi_stationで検証
    params_def_data_jcgi_station = @api_data.load_input_params("jcgi_station")


    # ================ orderデータ定義 ================
    # パラメータが存在する一般的なorderデータの場合
    order_group_yaml_standard = <<ORDER_GROUP_STANDARD
apis:
- cgi_station
- jcgi_station
- cgi_busstop
- jcgi_busstop
- cgi_landmark
- jcgi_landmark
- cgi_fromto_station
- jcgi_fromto_station
- jcgi_station_from_geopoint
- cgi_select_station
- cgi_select_station_landmark
params:
- name: val_in_name
- name: val_in_fromname
- name: val_in_toname
- name: val_lat_d
- name: val_lon_d
- name: val_lat
- name: val_lon
- name: val_radius
- name: val_area
- name: val_station_sort
- name: val_datum
- name: val_sttypefilter
- name: val_sttypefilter_default
- name: val_stationonly
- name: val_station_type
- name: val_landmark_type
ORDER_GROUP_STANDARD

    # APIの名前が含まれない場合
    order_group_yaml_not_include_apis = <<ORDER_GROUP_NOT_INCLUDE_APIS
apis:
- cgi_result2
params:
- name: val_from
ORDER_GROUP_NOT_INCLUDE_APIS

    # 存在するパラメータが1つも無い場合
    order_group_yaml_not_exist_params = <<ORDER_GROUP_NOT_EXIST_PARAMS
apis:
- jcgi_station
params:
- name: val_from
- name: val_to
ORDER_GROUP_NOT_EXIST_PARAMS

    # 型エラー
    order_group_yaml_error_class = <<ORDER_GROUP_ERROR_CLASS
- "Hashじゃない"
ORDER_GROUP_ERROR_CLASS

    # apis要素がない
    order_group_yaml_error_no_apis = <<ORDER_GROUP_ERROR_NO_APIS
params:
- name: val_from
- name: val_to
ORDER_GROUP_ERROR_NO_APIS

    # params要素がない
    order_group_yaml_error_no_params = <<ORDER_GROUP_ERROR_NO_PARAMS
apis:
- jcgi_result2
ORDER_GROUP_ERROR_NO_PARAMS

    order_group_data_standard = YAML::load(order_group_yaml_standard)
    order_group_data_not_include_apis = YAML::load(order_group_yaml_not_include_apis)
    order_group_data_not_exist_params = YAML::load(order_group_yaml_not_exist_params)
    order_group_data_error_class = YAML::load(order_group_yaml_error_class)
    order_group_data_not_error_no_apis = YAML::load(order_group_yaml_error_no_apis)
    order_group_data_not_error_no_params = YAML::load(order_group_yaml_error_no_params)


    # ================ 結果データ定義 ================
    result_yaml_standard = <<RESULT_STANDARD
params:
- name: val_in_name
  status: required
  comment: 取得したい駅名の一部
- name: val_area
  comment: 取得したい路線の地域
  value: 0：全国&1：北海道&2：東北&3：関東&4：中部&5：近畿&6：中国&7：四国&8：九州
  valueSkip: 0
- name: val_sttypefilter
  comment: 駅種別ごとのフィルタリング
  value: (「val_stationonly」指定時は無効)
  valueSkip: 「val_stationonly」の設定を適用
- name: val_sttypefilter_default
  comment: 「val_sttypefilter」の各桁を省略した場合の値
  value: 0：駅候補に含めない&1：駅候補に含める
  valueSkip: 1
- name: val_stationonly
  comment: 駅候補の詳細設定(「val_sttypefilter」を推奨)
  value: 0：駅候補に高速バス・連絡バスを含む&1：駅候補に高速バス・連絡バスを含まない
  valueSkip: 0
RESULT_STANDARD

    result_data_standard = YAML::load(result_yaml_standard)
    result_data_not_include_apis = {}
    result_data_not_exist_params = {}


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:generate_display_data,
                                                "jcgi_station",
                                                params_def_data_jcgi_station,
                                                order_group_data_error_class)
    end
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:generate_display_data,
                                                "jcgi_station",
                                                params_def_data_jcgi_station,
                                                order_group_data_not_error_no_apis)
    end
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:generate_display_data,
                                                "jcgi_station",
                                                params_def_data_jcgi_station,
                                                order_group_data_not_error_no_params)
    end

    display_group_data_standard = nil
    display_group_data_not_include_apis = nil
    display_group_data_not_exist_params = nil
    assert_nothing_raised do
      display_group_data_standard = 
        @helper_input_param_display_data.__send__(:get_display_group_data,
                                                  "jcgi_station",
                                                  params_def_data_jcgi_station,
                                                  order_group_data_standard)
      display_group_data_not_include_apis = 
        @helper_input_param_display_data.__send__(:get_display_group_data,
                                                  "jcgi_station",
                                                  params_def_data_jcgi_station,
                                                  order_group_data_not_include_apis)
      display_group_data_not_exist_params = 
        @helper_input_param_display_data.__send__(:get_display_group_data,
                                                  "jcgi_station",
                                                  params_def_data_jcgi_station,
                                                  order_group_data_not_exist_params)
    end
    assert_equal(result_data_standard,display_group_data_standard)
    assert_equal(result_data_not_include_apis,display_group_data_not_include_apis)
    assert_equal(result_data_not_exist_params,display_group_data_not_exist_params)
  end




  def test_generate_display_data
    # ================ orderデータ定義 ================
    order_data = @view_data.load_input_order
    # 不正値
    order_yaml_error = <<ORDER_ERROR
---
groupComment: 1-1 基本入力パラメータ(平均)
params:
- name: val_htmb
  inputType: system
  status: required
  comment: API名
ORDER_ERROR

    order_data_error = YAML::load(order_yaml_error)


    # ================ パラメータデータ定義 ================
    # groupCommentがある
    # refがある
    # 存在するパラメータが1つもないグループあり(groupCommentあり)
    params_def_data_cgi_details2 = @api_data.load_input_params("cgi_details2")
    # groupCommentがない
    # 存在するパラメータが1つもないグループあり(groupCommentなし)
    params_def_data_jcgi_station = @api_data.load_input_params("jcgi_station")
    # 不正値
    params_def_data_error = ["Hashじゃない"]


    # ================ 結果データ定義 ================
    result_yaml_cgi_details2 = <<RESULT_CGI_DETAILS2
---
- groupComment: 1-1 基本入力パラメータ(平均)
  params:
  - name: val_htmb
    inputType: system
    status: required
    comment: API名
  - name: val_cgi_url
    inputType: system
    status: required
    comment: 呼び出すCGIのURL
  - name: val_from
    isStation: true
    status: required
    comment: 出発駅の駅名(ロングネーム)
  - name: val_to
    isStation: true
    status: cond-required
    comment: 目的駅の駅名(ロングネーム)(経由駅を指定しない場合)
  - name: val_to01
    isStation: true
    status: cond-required
    comment: 経由駅または目的駅の駅名1(ロングネーム)
  - name: val_to02
    isStation: true
    status: cond-required
    comment: 経由駅または目的駅の駅名2(ロングネーム)
  - name: val_to03
    isStation: true
    status: cond-required
    comment: 経由駅または目的駅の駅名3(ロングネーム)
  - name: val_to04
    isStation: true
    status: cond-required
    comment: 経由駅または目的駅の駅名4(ロングネーム)
- groupComment: 1-3 探索条件(平均)
  params:
  - name: val_year
    comment: 出発日の年
    valueSkip: 本日日付(年・月・日いずれかの省略で適用)
  - name: val_month
    comment: 出発日の月
    valueSkip: 本日日付(年・月・日いずれかの省略で適用)
  - name: val_day
    comment: 出発日の日
    valueSkip: 本日日付(年・月・日いずれかの省略で適用)
  - name: val_feeling
    comment: 探索条件
    valueSkip: 2221122
  - name: val_expressonly
    comment: 探索条件：有料特急
    value: 0：利用しない&1：利用する
    valueSkip: 1
  - name: val_shinkansen
    comment: 探索条件：新幹線
    value: 0：利用しない&1：利用する
    valueSkip: 1
  - name: val_nozomi
    comment: 探索条件：のぞみ
    value: 0：利用しない&1：利用する
    valueSkip: 1
  - name: val_sleepingcar
    comment: 探索条件：寝台列車
    value: y：優先して利用&n：利用しない
    valueSkip: n
  - name: val_highwaybus
    comment: 探索条件：高速バス
    value: 1：優先して利用&2：普通に利用&3：極力利用しない
    valueSkip: 2
  - name: val_airbus
    comment: 探索条件：連絡バス
    value: 1：優先して利用&2：普通に利用&3：極力利用しない
    valueSkip: 2
  - name: val_ship
    comment: 探索条件：船
    value: 1：優先して利用&2：普通に利用&3：極力利用しない
    valueSkip: 2
  - name: val_bus_route_only
    comment: バスのみ探索
    value: y：利用する&n：利用しない
    valueSkip: n
- groupComment: 1-5 共通探索条件
  params:
  - name: val_oneway
    comment: 運賃種類
    value: 1：片道運賃&0：往復運賃&2：定期代
    valueSkip: 1
  - name: val_icticket
    comment: ICカード乗車券の計算
    value: 0：計算しない&1：計算する
    valueSkip: 0
  - name: val_dcstudent
    comment: 学割乗車券の計算
    value: 0：計算しない&1：計算する
    valueSkip: 0
  - name: val_teikifare_mode
    comment: 定期種類
    value: 1：通勤定期&2：高校生用通学定期&3：大学生用通学定期
    valueSkip: 1
  - name: val_jr2sectteiki
    comment: ＪＲ二区間定期
    value: 0：適時計算する&1：常に計算する
    valueSkip: 0
  - name: val_doubleroute
    comment: 2ルート定期
    value: 0：計算しない&1：計算する
    valueSkip: 0
  - name: val_confload
    inputType: disabled
    devtoolComment: 本ツールでは利用不可
    comment: 環境設定ファイルから値の取得モード
    valueSkip: 全ての桁に0を適用
  - name: val_sorttype
    comment: 探索結果の並び順
    value: 1：探索順&2：運賃順&3：所要時間順&4：定期順&5：乗換回数順&6：CO2排出量順&7：定期1ヵ月順&8：定期3ヵ月順&9：定期6ヵ月順
    valueSkip: 1
  - name: val_surcharge_type
    comment: 特急料金のタイプを指定
    value: 1：指定席&2：自由席&3：グリーン席
    valueSkip: 1
  - name: val_jrconsideration
    comment: 繁忙期・閑散期を考慮した探索
    value: y：考慮する、n：考慮しない
    valueSkip: y
  - name: val_airfare_mode
    comment: 航空保険特別料金
    value: 0：運賃に含まない&1：運賃に含む
    valueSkip: 0
  - name: val_airport_charge
    comment: 空港使用料の出力
    value: 0：出力しない、1：出力する
    valueSkip: 0
  - name: val_max_result
    comment: 探索結果の回答数の最大値
    value: 1～20
    valueSkip: 5
- groupComment: 1-6 探索結果のカスタマイズ
  params:
  - name: val_cstm[cstmNo]_r[routeNo]_type
    inputType: disabled
    devtoolComment: 本ツールでは利用不可
    comment: カスタマイズタイプ(1経路)
    value: TeikiClassを指定
  - name: val_cstm1_all_type
    devtoolComment: 本ツールでは1件のみ指定可
    comment: カスタマイズタイプ(全経路)
    value: TeikiClassを指定
  - name: val_cstm1_tkcls_seq
    devtoolComment: 本ツールでは1件のみ指定可
    comment: 定期券区間番号
  - name: val_cstm1_tkcls
    devtoolComment: 本ツールでは1件のみ指定可
    comment: 定期クラス
    value: 2Section：二区間定期&passage：区間外定期&general：一般定期&wRoute：だぶるーと&t2Route：二区間定期券&s2Route：Oneだぶる♪
- groupComment: 1-7 使用路線の指定
  params:
  - name: val_noritugi01
    comment: 1番目の路線区間の使用路線(ロングネーム)
  - name: val_noritugi02
    comment: 2番目の路線区間の使用路線(ロングネーム)
  - name: val_noritugi03
    comment: 3番目の路線区間の使用路線(ロングネーム)
  - name: val_noritugi04
    comment: 4番目の路線区間の使用路線(ロングネーム)
- groupComment: 1-8 不通路線の指定
  params:
  - name: val_use_stopsect
    comment: 不通路線または会社を考慮した探索
    value: y：考慮する&n：考慮しない
    valueSkip: n
  - name: val_stopsect01
    comment: 利用しない路線名または路線会社名1(ロングネーム)
  - name: val_stopsect02
    comment: 利用しない路線名または路線会社名2(ロングネーム)
  - name: val_stopsect03
    comment: 利用しない路線名または路線会社名3(ロングネーム)
  - name: val_stopsect04
    comment: 利用しない路線名または路線会社名4(ロングネーム)
  - name: val_stopsect05
    comment: 利用しない路線名または路線会社名5(ロングネーム)
  - name: val_stopsect06
    comment: 利用しない路線名または路線会社名6(ロングネーム)
  - name: val_stopsect07
    comment: 利用しない路線名または路線会社名7(ロングネーム)
  - name: val_stopsect08
    comment: 利用しない路線名または路線会社名8(ロングネーム)
  - name: val_stopsect09
    comment: 利用しない路線名または路線会社名9(ロングネーム)
  - name: val_stopsect10
    comment: 利用しない路線名または路線会社名10(ロングネーム)
- groupComment: 1-9 その他の入力パラメータ
  params:
  - name: val_outpara_cookie
    inputType: disabled
    devtoolComment: 本ツールでは利用不可
    comment: 出力されたパラメータをCookieに書き込む
    value: y：書き込む&n：書き込まない
    valueSkip: n
  - name: val_connect_id
    inputType: disabled
    devtoolComment: 本ツールでは利用不可
    comment: 同時接続ID
- groupComment: 3-1 定期券利用時の運賃計算(詳細な計算結果)
  params:
  - name: val_tassignmode
    devtoolComment: 本ツールでは"1"は利用不可
    comment: 定期券利用時の運賃計算(詳細な計算結果)
    value: 1：定期券利用時の登録名での運賃計算&2：駅名・路線名による運賃計算&3：方向性を持った経路文字列で計算
    valueSkip: 無効
  - name: val_tassign_reflect
    comment: 探索結果への反映
    value: 0：反映しない&1：反映する
    valueSkip: 0
  - name: val_tassign_year
    comment: 定期券情報を復元する年
    valueSkip: 出発日(年・月・日いずれかの省略で適用)
  - name: val_tassign_month
    comment: 定期券情報を復元する月
    valueSkip: 出発日(年・月・日いずれかの省略で適用)
  - name: val_tassign_day
    comment: 定期券情報を復元する日
    valueSkip: 出発日(年・月・日いずれかの省略で適用)
  - name: val_tassign_liketeikiuse
    comment: val_teiki_route利用時の出力パラメータを模倣して出力
    value: 0：出力しない&1：出力する
    valueSkip: 0
  - name: val_tassign_entryname
    inputType: disabled
    devtoolComment: 本ツールでは利用不可
    comment: 定期券利用区間登録名
  - name: val_tassign_stationnamelist
    comment: 定期券利用区間駅名リスト
  - name: val_tassign_railnamelist
    comment: 定期券利用区間路線名リスト
  - name: val_tassign_restoreroute
    comment: 方向性を持った経路文字列
  - name: val_tassign_jr2sectteiki
    comment: ＪＲ二区間定期
    value: 0：適時計算する&1：常に計算する
    valueSkip: 0
  - name: val_tassign_doubleroute
    comment: 2ルート定期
    value: 0：計算しない&1：計算する
    valueSkip: 0
  - name: val_tassign_tkcls_1
    devtoolComment: 本ツールでは定期券区間1のみ指定可
    comment: 定期券利用区間の定期クラス
    value: 2Section：二区間定期&passage：区間外定期&general：一般定期&wRoute：だぶるーと&t2Route：二区間定期券&s2Route：Oneだぶる♪
- groupComment: 3-2 定期券利用時の運賃計算
  params:
  - name: val_teiki_route
    devtoolComment: 本ツールでは"1"は利用不可
    comment: 定期券利用時の運賃計算
    value: 1：定期券利用時の登録名での運賃計算&2：駅名・路線名による運賃計算&3：方向性を持った経路文字列で計算
    valueSkip: 無効
  - name: val_teiki_year
    comment: 定期券情報を復元する年
    valueSkip: 出発日(例外あり)(年・月・日いずれかの省略で適用)
  - name: val_teiki_month
    comment: 定期券情報を復元する月
    valueSkip: 出発日(例外あり)(年・月・日いずれかの省略で適用)
  - name: val_teiki_day
    comment: 定期券情報を復元する日
    valueSkip: 出発日(例外あり)(年・月・日いずれかの省略で適用)
  - name: val_teikiuse_key
    inputType: disabled
    devtoolComment: 本ツールでは利用不可
    comment: 定期券利用区間登録名
  - name: val_teiki_station_cnt
    comment: 定期券利用区間駅数
  - name: val_teiki_stationnamelist
    comment: 定期券利用区間駅名リスト
  - name: val_teiki_rail_cnt
    comment: 定期券利用区間路線数
  - name: val_teiki_railnamelist
    comment: 定期券利用区間路線名リスト
  - name: val_teikirestore
    comment: 方向性を持った経路文字列
- groupComment: 3-3 回数券利用時の運賃計算
  params:
  - name: val_coupon_data
    comment: 回数券情報
    valueSkip: 無効
- groupComment: 3-4 分割定期計算
  params:
  - name: val_separate_route
    comment: 分割定期計算の有無
    value: y：計算する&n：計算しない
    valueSkip: n
- groupComment: 3-5 二酸化炭素(CO2)排出量のパラメータ
  params:
  - name: val_co2mode
    comment: 二酸化炭素(CO2)排出量
    value: 0：出力しない&1：出力する
    valueSkip: 0
- groupComment: 3-6 路線色
  params:
  - name: val_linecolor
    comment: 路線色の出力
    value: 0：出力しない&1：出力する
    valueSkip: 0
- groupComment: 3-7 ユーザーパラメータ
  params:
  - name: val_upperparam
    comment: パラメータ名称の大文字小文字を区別する
    value: y：区別する&n：区別しない
    valueSkip: n
RESULT_CGI_DETAILS2

    result_yaml_jcgi_station = <<RESULT_JCGI_STATION
---
- params:
  - name: val_htmb
    inputType: system
    status: required
    comment: API名
- params:
  - name: val_in_name
    status: required
    comment: 取得したい駅名の一部
  - name: val_area
    comment: 取得したい路線の地域
    value: 0：全国&1：北海道&2：東北&3：関東&4：中部&5：近畿&6：中国&7：四国&8：九州
    valueSkip: 0
  - name: val_sttypefilter
    comment: 駅種別ごとのフィルタリング
    value: (「val_stationonly」指定時は無効)
    valueSkip: 「val_stationonly」の設定を適用
  - name: val_sttypefilter_default
    comment: 「val_sttypefilter」の各桁を省略した場合の値
    value: 0：駅候補に含めない&1：駅候補に含める
    valueSkip: 1
  - name: val_stationonly
    comment: 駅候補の詳細設定(「val_sttypefilter」を推奨)
    value: 0：駅候補に高速バス・連絡バスを含む&1：駅候補に高速バス・連絡バスを含まない
    valueSkip: 0
- params:
  - name: val_connect_id
    inputType: disabled
    devtoolComment: 本ツールでは利用不可
    comment: 同時接続ID
RESULT_JCGI_STATION

    result_data_cgi_details2 = YAML::load(result_yaml_cgi_details2)
    result_data_jcgi_station = YAML::load(result_yaml_jcgi_station)


    # ================ テスト実行 ================
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:generate_display_data,
                                                "cgi_details2",
                                                params_def_data_cgi_details2,
                                                order_data_error)
    end
    assert_raise(ArgumentError) do
      @helper_input_param_display_data.__send__(:generate_display_data,
                                                "cgi_details2",
                                                params_def_data_error,
                                                order_data)
    end

    display_data_cgi_details2 = nil
    display_data_jcgi_station = nil
    assert_nothing_raised do
      display_data_cgi_details2 = @helper_input_param_display_data.__send__(:generate_display_data,
                                                                            "cgi_details2",
                                                                            params_def_data_cgi_details2,
                                                                            order_data)
      display_data_jcgi_station = @helper_input_param_display_data.__send__(:generate_display_data,
                                                                            "jcgi_station",
                                                                            params_def_data_jcgi_station,
                                                                            order_data)
    end
    assert_equal(result_data_cgi_details2,display_data_cgi_details2)
    assert_equal(result_data_jcgi_station,display_data_jcgi_station)
  end
end
