# -*- coding: utf-8 -*-

require_relative "output_common"

module V2apiDevTool
  module Controller
    module Helper
      #
      # outputコントローラで使用するヘルパーメソッド(レスポンス関連)
      #
      module OutputResponse
        include Helper::OutputCommon
        private

        #
        # 出力パラメータデータの読み込み
        #
        def load_param_data(api_name,api_data)
          api_data.load_output_params(api_name)
        end

      end
    end
  end
end
