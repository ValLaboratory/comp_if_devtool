# -*- coding: utf-8 -*-

module V2apiDevTool
  module Controller
    module Helper
      #
      # 入力パラメータ表示データ関連のヘルパーメソッド
      #
      module InputParamDisplayData
        private

        #
        # 入力パラメータ表示データの1パラメータ分のデータを生成
        #   params_def_data  -> API個別のパラメータ定義データ
        #   order_param_data -> 表示順定義データ(1パラメータ)(Hash)
        #
        def get_display_param_data(params_def_data,order_param_data)
          unless order_param_data.class == Hash
            raise ArgumentError, "input_orderファイルエラー"
          end
          unless order_param_data["name"]
            raise ArgumentError, "input_orderファイルエラー"
          end

          display_param_data = {}

          name = order_param_data["name"]
          ref_name = order_param_data["ref"] || name  # param_def_dataの参照用パラメータ名称

          param_def_data = params_def_data[ref_name]
          # パラメータが存在しない場合、初期値の空Hashを返す
          if param_def_data

            # order_param_dataの各要素を、display_param_dataにコピー
            # ただし、以下のキーは除く
            # ref .. 不要なため
            order_param_data.each_key do |key|
              if key == "ref" then next end
              display_param_data[key] = order_param_data[key]
            end

            # param_def_dataの各要素を、display_param_dataにコピー
            param_def_data.each_key do |key|
              display_param_data[key] = param_def_data[key]
            end
          end

          return display_param_data
        end

        #
        # 入力パラメータ表示データの1グループ分のデータを生成
        #   api_name         -> APIの名称
        #   params_def_data  -> API個別のパラメータ定義データ
        #   order_group_data -> 表示順定義データ(1グループ)(Hash)
        #
        def get_display_group_data(api_name,params_def_data,order_group_data)
          unless order_group_data.class == Hash
            raise ArgumentError, "input_orderファイルエラー"
          end
          unless order_group_data["apis"] && order_group_data["params"]
            raise ArgumentError, "input_orderファイルエラー"
          end

          display_group_data = {}

          # APIがグループの対象APIに含まれない場合、初期値の空Hashを返す
          if order_group_data["apis"].include?(api_name)

            # order_group_dataの各要素を、display_group_dataにコピー
            # ただし、以下のキーは除く
            # apis   .. 不要なため
            # params .. 以下で加工するため
            order_group_data.each_key do |key|
              if ["apis","params"].include?(key) then next end
              display_group_data[key] = order_group_data[key]
            end

            # paramsの取得
            params_data = []
            order_group_data["params"].each do |order_param_data|
              param_data = get_display_param_data(params_def_data,order_param_data)
              params_data << param_data if param_data.length > 0
            end

            # paramsがあれば返却するデータに反映
            # なければ空ハッシュを返却
            if params_data.length > 0
              display_group_data["params"] = params_data
            else
              display_group_data = {}
            end

          end

          return display_group_data
        end

        #
        # 入力パラメータ表示データを生成
        #   api_name        -> APIの名称
        #   params_def_data -> API個別のパラメータ定義データ
        #   order_data      -> 表示順定義データ(Array)
        #
        def generate_display_data(api_name,params_def_data,order_data)
          unless order_data.class == Array
            raise ArgumentError, "input_orderファイルエラー"
          end
          unless params_def_data.class == Hash
            raise ArgumentError, "param_defファイルエラー"
          end

          display_data = []

          # 表示グループごとに取得
          order_data.each do |order_group_data|
            group_data = get_display_group_data(api_name,params_def_data,order_group_data)
            display_data << group_data if group_data.length > 0
          end

          return display_data
        end
      end
    end
  end
end
