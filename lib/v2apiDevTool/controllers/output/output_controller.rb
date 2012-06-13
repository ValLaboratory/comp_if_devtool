# -*- coding: utf-8 -*-

module V2apiDevTool
  module Controller
    #
    # outputルーティング用コントローラ
    # 利用時は用途に応じてこのクラスを継承する子クラスを利用のこと
    #
    class OutputController
      #
      # args
      #   api_name -> (String)名称
      #   request_vars -> クエリ文字列形式のリクエストパラメータ(Rack変数から取得)
      #   settings -> Sinatra設定データ
      #   encoding -> リクエストの文字コード
      #
      def initialize(api_name,request_vars,settings,encoding)
        @api_name = api_name
        @request_vars = request_vars
        @settings = settings
        @encoding = encoding
      end
    end
  end
end
