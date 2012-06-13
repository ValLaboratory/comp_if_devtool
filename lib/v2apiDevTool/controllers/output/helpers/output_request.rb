# -*- coding: utf-8 -*-

require_relative "output_common"

module V2apiDevTool
  module Controller
    module Helper
      #
      # outputコントローラで使用するヘルパーメソッド(リクエスト関連)
      #
      module OutputRequest
        include Helper::OutputCommon
        private

        #
        # アプリケーション独自のパラメータを削除する
        #   v2_request -> パラメータ(キーにパラメータ名、値にその対応する値をもつHash)
        #
        def delete_devtool_param(v2_request)
          pure_request = v2_request.dup
          pure_request.delete_if do |key,value|
            /^val_v2api_dev_tool_/ =~ key
          end
          return pure_request
        end
      end
    end
  end
end
