# -*- coding: utf-8 -*-

require_relative "helpers/input_common"
require_relative "helpers/input_param_display_data"

module V2apiDevTool
  module Controller
    #
    # inputルーティング用コントローラ
    # 入力画面用データ生成を行う
    #
    class InputController
      include Helper::InputCommon
      include Helper::InputParamDisplayData

      #
      # args
      #   api_name -> (String)名称
      #   settings -> Sinatra設定データ
      #
      def initialize(api_name,settings)
        @api_name = api_name
        @settings = settings
      end

      #
      # ビュー表示用データの取得(パラメータデータの取得と変換)
      #
      def get_display_data
        param_data = load_param_data(@api_name,@settings.api_data)
        display_data = generate_display_data(@api_name,param_data,@settings.input_order)
        return display_data
      end
    end
  end
end
