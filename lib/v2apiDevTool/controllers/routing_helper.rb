# -*- coding: utf-8 -*-

module V2apiDevTool
  module Controller
    #
    # ルーティングメソッド内で利用するヘルパーメソッド
    #
    module RoutingHelper
      #
      # v2apiの名称判定
      # 存在する場合は名称を返す
      # 存在しない(使用不可)場合は例外を投げる
      # args
      #   api_name    -> (String)名称
      #
      def check_v2api_name(api_name)
        # 存在しない場合
        if settings.v2APIs.has_key?(api_name) == false
          raise ArgumentError, "指定されたAPIは存在しません"
        end
        # V2のみのAPIで、ENVがproductionの場合
        if settings.v2APIs[api_name]["intraV2Only"] == true && settings.environment == :production
          raise ArgumentError, "指定されたAPIは存在しません"
        end

        return api_name
      end

      #
      # v2apiの種類を求める
      # return
      #   cgiの場合  -> :cgi
      #   jcgiの場合 -> :jcgi
      #   それ以外   -> 例外
      #
      def v2api_kind(api_name)
        api_data = settings.v2APIs[api_name]
        unless api_data
          raise ArgumentError, "指定されたAPIは存在しません"
        end

        case api_data["apiType"]
        when "cgi"
          return :cgi
        when "jcgi"
          return :jcgi
        else
          raise "\"apiType\"が不正です"
        end
      end

      #
      # erubisのビューをcp932で出力
      #
      def erubis_cp932(template, options={}, locals={})
        view = erubis template, options, locals
        [200, {"Content-Type" => "text/html;charset=shift_jis"}, view.encode("cp932")]
      end
    end
  end
end
