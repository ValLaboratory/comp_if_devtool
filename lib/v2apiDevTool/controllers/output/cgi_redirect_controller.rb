# -*- coding: utf-8 -*-

require_relative "output_controller"
require_relative "helpers/output_request"

module V2apiDevTool
  module Controller
    #
    # CGIへのリクエスト発行用のリダイレクトビューで使用するデータを生成する
    #
    class CgiRedirectController < OutputController
      include Helper::OutputRequest

      #
      # リダイレクト用ビューに渡すリクエストパラメータを生成し返す
      #
      def get_redirect_request
        v2_request = convert_www_form_vars(@request_vars,"utf-8","utf-8")
        redirect_request = delete_devtool_param(v2_request)
        return redirect_request
      end
    end
  end
end
