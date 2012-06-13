# -*- coding: utf-8 -*-

require_relative "output_controller"
require_relative "helpers/output_response"
require_relative "helpers/output_param_display_data"

module V2apiDevTool
  module Controller
    #
    # CGIからのレスポンスから、ビュー表示用データを生成する
    #
    class CgiOutputController < OutputController
      include Helper::OutputResponse
      include Helper::OutputParamDisplayData

      #
      # ビュー表示用データの取得(パラメータデータの取得と変換)
      #
      def get_display_data
        param_data = load_param_data(@api_name,@settings.api_data)
        v2_response = convert_www_form_vars(@request_vars,@encoding,"utf-8")
        display_data = generate_display_data(@api_name,param_data,@settings.output_order,v2_response)
        return display_data
      end
    end
  end
end
