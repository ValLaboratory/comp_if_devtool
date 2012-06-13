# -*- coding: utf-8 -*-

module V2apiDevTool
  module Controller
    module Helper
      #
      # 出力パラメータ表示データ関連のヘルパーメソッド
      #
      module OutputParamDisplayData
        private

        # ========================================================
        #                 definedParams関連
        # ========================================================

        #
        # 変数と値のHash、static_countsに要素を追加する
        #
        def add_static_count(static_counts,add_count_name,add_count_number)
          new_counts = static_counts.clone
          new_counts[add_count_name] = add_count_number
          return new_counts
        end

        #
        # param_name中の[(変数名)]部分を置換
        # 置換する変数は、Hashで与える
        #
        def replace_counts(param_name,counts_with_value)
          result = param_name
          counts_with_value.each do |c_name,c_value|
            result = result.gsub(/\[#{c_name}\]/,c_value.to_s)
          end
          return result
        end

        #
        # response(Hash)の中から、キー値がparam_name_baseのものを取得する。
        # param_name_baseに[(変数名)]が含まれる場合、
        # 該当する箇所を数字に置き換えたパラメータ全てをマッチさせる。
        # 戻り値はArray
        #
        def get_param_names_from_response(param_name_base,response)
          param_names = []

          # param_name_baseがキーとなる値がすでにあれば、それだけを返す
          if response[param_name_base]
            param_names << param_name_base
          else
            # レスポンスのキーにマッチさせる正規表現を生成
            pattern_str = param_name_base.gsub(/\[.+?\]/,"\\d+?")
            pattern_str = "^" + pattern_str + "$"
            pattern = Regexp.new(pattern_str)

            response.keys.each do |key|
              if pattern =~ key
                param_names << key
              end
            end
          end

          return param_names
        end

        #
        # 出力パラメータの子関係のパラメータ群を生成
        # order_param_data["numberOf"]で示される変数名から、
        # 該当する変数部分を1からmax_countまでの数字に置換したパラメータを、
        # 子要素として取得する
        # children要素は、get_display_params_dataメソッドを再帰することで取得される
        # Arguments
        #   params_def_data  -> API個別のパラメータ定義データ
        #   order_param_data -> 表示順定義データ(1パラメータ)
        #   response         -> イントラからのレスポンス(Hash)
        #   max_count        -> order_param_data["numberOf"]で示される変数の取る最大値(Integer)
        #   static_counts    -> (Hash)数字に置き換える変数名称(key)と値(value)
        # Returns
        #   display_children_data -> 出力パラメータの子要素群の表示データ
        #   display_param_names   -> 表示データに含まれる出力パラメータの名称(Array)
        #
        def get_display_children_data(params_def_data,order_param_data,response,max_count,static_counts)
          unless order_param_data.class == Hash
            raise ArgumentError, "output_orderファイルエラー"
          end
          unless order_param_data["children"]
            raise ArgumentError, "output_orderファイルエラー"
          end
          unless order_param_data["numberOf"]
            raise ArgumentError, "output_orderファイルエラー"
          end
          unless max_count.kind_of?(Integer)
            raise ArgumentError, "max_countエラー"
          end

          display_children_data = []
          display_param_names = []

          # 対象の変数部分を示す文字列
          count_name = order_param_data["numberOf"]

          # 各count番号について子パラメータを生成
          (1 .. max_count).each do |count_num|
            display_children_group_data = {}

            # 各count番号に対するコメント
            count_group_comment = order_param_data["countGroupNumberComment"]
            if count_group_comment
              display_children_group_data["countGroupNumberComment"] = count_group_comment + count_num.to_s
            end

            # 変数部分をcount_numに応じて設定
            next_static_counts = add_static_count(static_counts,count_name,count_num)

            # params要素の生成
            order_children_data = order_param_data["children"]
            display_children_params_data, param_names = get_display_params_data(params_def_data,order_children_data,response,next_static_counts)
            display_children_group_data["params"] = display_children_params_data if display_children_params_data.length > 0
            display_param_names += param_names

            # children要素に格納
            display_children_data << display_children_group_data
          end

          return display_children_data, display_param_names
        end

        #
        # 出力パラメータの1パラメータと、その子関係のパラメータ群を生成
        # response_nameがcount系パラメータである場合、
        # children要素についてのパラメータ生成処理を呼び出す
        # Arguments
        #   params_def_data  -> API個別のパラメータ定義データ
        #   order_param_data -> 表示順定義データ(1パラメータ)
        #   response         -> イントラからのレスポンス(Hash)
        #   response_name    -> 処理するパラメータ名称(responseのキーに存在する名称)
        #   static_counts    -> (Hash)数字に置き換える変数名称(key)と値(value)
        # Returns
        #   display_param_data  -> 出力パラメータ1パラメータ(と子要素)の表示データ
        #   display_param_names -> 表示データに含まれる出力パラメータの名称(Array)
        #
        def get_display_param_data(params_def_data,order_param_data,response,response_name,static_counts)
          unless order_param_data.class == Hash
            raise ArgumentError, "output_orderファイルエラー"
          end
          unless order_param_data["name"]
            raise ArgumentError, "output_orderファイルエラー"
          end
          unless response_name.class == String
            raise ArgumentError, "response_nameエラー"
          end
          unless response[response_name]
            raise ArgumentError, "response_nameエラー"
          end

          display_param_data = {}
          display_param_names = []
          ref_name = order_param_data["name"]  # params_def_data参照用

          # order_param_dataの各要素を、display_param_dataにコピー
          # ただし、以下のキーは除く
          # ref                     .. 不要なため
          # numberOf                .. 不要なため
          # countGroupNumberComment .. 以下で加工するため
          # name                    .. 以下で加工するため
          # children                .. 以下で加工するため
          order_param_data.each_key do |key|
            if ["ref","numberOf","countGroupNumberComment","name","children"].include?(key) then next end
            display_param_data[key] = order_param_data[key]
          end

          # params_def_dataの各要素を、display_param_dataにコピー
          params_def_data[ref_name].each_key do |key|
            display_param_data[key] = params_def_data[ref_name][key]
          end

          # レスポンスのキーと値を設定
          display_param_data["name"] = response_name
          display_param_data["responseValue"] = response[response_name]
          # 表示データに使用したのでdisplay_param_namesに追加
          display_param_names << response_name

          # count系パラメータの場合、下の階層のパラメータデータを求める
          if order_param_data["numberOf"]
            max_count = response[response_name].to_i
            display_children_data, param_names = get_display_children_data(params_def_data,order_param_data,response,max_count,static_counts)
            display_param_data["children"] = display_children_data if display_children_data.length > 0
            display_param_names += param_names
          end

          return display_param_data, display_param_names
        end

        #
        # 出力パラメータのparams要素を生成
        # count系パラメータのchildren要素に含まれるparams要素は、
        # このメソッドを再帰して生成される
        # Arguments
        #   params_def_data   -> API個別のパラメータ定義データ
        #   order_params_data -> 表示順定義データ(1パラメータグループ)
        #   response          -> イントラからのレスポンス(Hash)
        #   static_counts     -> (Hash)数字に置き換える変数名称(key)と値(value)
        #                        デフォルトは空ハッシュ
        # Returns
        #   display_params_data -> 出力パラメータ1パラメータグループの表示データ
        #   display_param_names -> 表示データに含まれる出力パラメータの名称(Array)
        #
        def get_display_params_data(params_def_data,order_params_data,response,static_counts = {})
          unless order_params_data.class == Array
            raise ArgumentError, "output_orderファイルエラー"
          end
          unless static_counts.class == Hash
            raise ArgumentError, "static_countsエラー"
          end

          display_params_data = []
          display_param_names = []

          # 表示順定義データ(order_params_data)のname要素は、
          # パラメータ定義データ(params_def_data)の参照用名称で定義しているため、
          # count系パラメータの数字部分について
          # 実際にresponseで取得したパラメータ名称と差異がある
          # このため、responseとして取得した該当パラメータ名称を取得してから、
          # 個々のパラメータ要素に対する処理を行う
          order_params_data.each do |order_param_data|
            ref_name = order_param_data["name"]

            param_def_data = params_def_data[ref_name]
            # パラメータが存在しない場合、何もしない
            # パラメータグループの全パラメータが存在しない場合、初期値の空配列が返る
            if param_def_data

              # nameの変数部分を変換し、完全な名称を取得する
              # "[routeNo]"などの変数部分を置換
              response_name_base = replace_counts(ref_name,static_counts)
              # レスポンスから該当するパラメータを抽出([(変数名)]が含まれるものについては全て)
              response_names = get_param_names_from_response(response_name_base,response)

              # レスポンスの各パラメータ名称ごとに処理
              response_names.each do |response_name|
                param_data, param_names = get_display_param_data(params_def_data,order_param_data,response,response_name,static_counts)
                display_params_data << param_data if param_data.length > 0
                display_param_names += param_names
              end
            end
          end

          return display_params_data, display_param_names
        end

        #
        # params_def_dataで定義されている出力パラメータの1グループ分のデータを生成
        # Arguments
        #   api_name         -> APIの名称
        #   params_def_data  -> API個別のパラメータ定義データ
        #   order_group_data -> 表示順定義データ(1グループ)
        #   response         -> イントラからのレスポンス(Hash)
        # Returns
        #   display_group_data  -> 出力パラメータ1グループの表示データ
        #   display_param_names -> 表示データに含まれる出力パラメータの名称(Array)
        #
        def get_display_group_data(api_name,params_def_data,order_group_data,response)
          unless order_group_data.class == Hash
            raise ArgumentError, "output_orderファイルエラー"
          end
          unless order_group_data["apis"] && order_group_data["params"]
            raise ArgumentError, "output_orderファイルエラー"
          end

          display_group_data = {}
          display_param_names = []

          # APIがグループの対象APIに含まれない場合、初期値の空Hashを返す
          if order_group_data["apis"].include?(api_name)

            # order_group_dataの各要素を、display_group_dataにコピー
            # ただし、以下のキーは除く
            # apis   .. 不要なため
            # params .. 以下で加工するため
            # (現状この2つ以外のキーは存在しないので実質何もしない)
            order_group_data.each_key do |key|
              if ["apis","params"].include?(key) then next end
              display_group_data[key] = order_group_data[key]
            end

            # paramsの取得
            order_params_data = order_group_data["params"]
            params_data, param_names = get_display_params_data(params_def_data,order_params_data,response)
            display_group_data["params"] = params_data
            display_param_names += param_names
          end

          return display_group_data, display_param_names
        end

        #
        # params_def_dataで定義されている出力パラメータの表示データを生成
        # Arguments
        #   api_name        -> APIの名称
        #   params_def_data -> API個別のパラメータ定義データ
        #   order_data      -> 表示順定義データ
        #   response        -> イントラからのレスポンス(Hash)
        # Returns
        #   defined_params_display_data -> 出力パラメータの表示データ
        #   display_param_names         -> 表示データに含まれる出力パラメータの名称(Array)
        # 
        # メソッドの呼び出しイメージ
        #   get_defined_params_display_data
        #                 v
        #       get_display_group_data
        #                 v
        #       get_display_params_data   <-----<
        #                 v                     |
        #       get_display_param_data          |
        #                 v                     |
        #      get_display_children_data  ------^
        #
        def get_defined_params_display_data(api_name,params_def_data,order_data,response)
          unless order_data.class == Array
            raise ArgumentError, "output_orderファイルエラー"
          end
          unless params_def_data.class == Hash
            raise ArgumentError, "param_defファイルエラー"
          end
          unless response.class == Hash
            raise ArgumentError, "responseエラー"
          end

          defined_params_display_data = []
          display_param_names = []

          # 表示グループごとに取得
          order_data.each do |order_group_data|
            group_data, param_names = get_display_group_data(api_name,params_def_data,order_group_data,response)
            defined_params_display_data << group_data if group_data.length > 0
            display_param_names += param_names
          end

          return defined_params_display_data, display_param_names
        end

        # ========================================================
        #                      routeString関連
        # ========================================================

        # 
        # 経路文字列を保持する要素の生成
        # resultの場合、String
        # detailsの場合、Array(各要素がStrinf)
        # Arguments
        #   response -> イントラからのレスポンス(Hash)
        #
        def get_route_string_data(response)
          route_string_data = nil

          if response["val_route_cnt"]
            route_strings = []
            count = response["val_route_cnt"].to_i
            (1 .. count).each do |i|
              route_strings << response["val_route_#{i}"]
            end
            route_string_data = route_strings
          elsif response["val_route"]
            route_string_data = response["val_route"]
          end

          return route_string_data
        end

        # ========================================================
        #                      userParams関連
        # ========================================================

        # 
        # ユーザーパラメータを保持する要素の生成
        # Arguments
        #   response -> イントラからのレスポンス(Hash)
        # Returns
        #   user_params_data -> ユーザーパラメータの表示データ
        #   user_param_names -> 表示データに含まれる出力パラメータの名称(Array)
        #
        def get_user_params_data(response)
          user_params_data = []
          user_param_names = []

          response.each do |key,value|
            if /^val_/ !~ key
              param = {}
              param["name"] = key
              param["responseValue"] = value

              user_params_data << param
              user_param_names << key
            end
          end

          return user_params_data, user_param_names
        end

        # ========================================================
        #                   notDefinedParams関連
        # ========================================================

        # 
        # 未定義のresponseパラメータを保持する要素を生成
        # Arguments
        #   response -> イントラからのレスポンス(Hash)
        #   defined_param_names -> 定義されているパラメータ(Array)
        #                          (ユーザーパラメータも含む)
        #
        def get_not_defined_params_display_data(response,defined_param_names)
          not_defined_params_data = []

          # 定義済み(definedParamsに含まれる)パラメータを取り除く
          notdef_response_params = response.dup
          defined_param_names.each do |name|
            notdef_response_params.delete(name)
          end

          # not_defined_params_dataの要素を形成
          notdef_response_params.each do |key,value|
            param = {}
            param["name"] = key
            param["responseValue"] = value
            not_defined_params_data << param
          end

          return not_defined_params_data
        end

        # ========================================================
        #                         main
        # ========================================================

        #
        # 出力パラメータ表示データを生成
        # Arguments
        #   api_name        -> APIの名称
        #   params_def_data -> API個別のパラメータ定義データ
        #   order_data      -> 表示順定義データ
        #   response        -> イントラからのレスポンス(Hash)
        #
        def generate_display_data(api_name,params_def_data,order_data,response)
          display_data = {}

          # 定義されている表示データと、その中に含まれるパラメータ名称を多重代入
          defined_params_data, display_param_names = get_defined_params_display_data(api_name,params_def_data,order_data,response)
          display_data["definedParams"] = defined_params_data

          route_string_data = get_route_string_data(response)
          display_data["routeString"] = route_string_data if route_string_data

          user_params_data, user_param_names = get_user_params_data(response)
          display_data["userParams"] = user_params_data if user_params_data.length > 0
          display_param_names += user_param_names

          not_defined_params_data = get_not_defined_params_display_data(response,display_param_names)
          display_data["notDefinedParams"] = not_defined_params_data if not_defined_params_data.length > 0

          return display_data
        end

      end
    end
  end
end
