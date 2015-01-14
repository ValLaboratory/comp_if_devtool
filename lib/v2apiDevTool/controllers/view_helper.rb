# -*- coding: utf-8 -*-

module V2apiDevTool
  module Controller
    module ViewHelper
      #
      # publicファイルのURL
      #
      def app_root_url
        "#{env["rack.url_scheme"]}://#{env["HTTP_HOST"]}#{env["SCRIPT_NAME"]}"
      end

      #
      # インクリメンタルサーチのリクエスト先URL
      #
      def incsearch_url
        settings.app_config["incSearchURL"]
      end

      #
      # param["value"]を&でセパレート
      #
      def split_values_comment(values_text)
        values_text.split("&")
      end

      #
      # 探索系APIかを判定する
      # return
      #   探索系の場合     -> true
      #   非探索系の場合   -> false
      #   api_nameが不正値 -> 例外
      #
      def is_tansaku_v2api?(api_name)
        api_data = settings.v2APIs[api_name]
        unless api_data
          raise ArgumentError, "指定されたAPIが存在しません"
        end

        return api_data["tansaku"]
      end

      #
      # ユーザーパラメータが使用可能かを判定する
      # return
      #   使用可           -> true
      #   使用不可         -> false
      #   api_nameが不正値 -> 例外
      #
      def enabled_user_param?(api_name)
        api_data = settings.v2APIs[api_name]
        unless api_data
          raise ArgumentError, "指定されたAPIが存在しません"
        end

        return api_data["userParam"]
      end

      #
      # Webサービスアクセスキー
      #
      def webapi_key
        settings.app_config["webapiKey"]
      end
    end
  end
end
