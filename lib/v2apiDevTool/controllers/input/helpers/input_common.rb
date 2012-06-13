# -*- coding: utf-8 -*-

module V2apiDevTool
  module Controller
    module Helper
      #
      # inputコントローラで使用するヘルパーメソッド
      #
      module InputCommon
        private

        #
        # 入力パラメータデータの読み込み
        #
        def load_param_data(api_name,api_data)
          api_data.load_input_params(api_name)
        end

      end
    end
  end
end
