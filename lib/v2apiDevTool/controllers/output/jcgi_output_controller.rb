# -*- coding: utf-8 -*-

require "uri"
require "net/http"
require_relative "output_controller"
require_relative "helpers/output_request"
require_relative "helpers/output_response"
require_relative "helpers/output_param_display_data"

module V2apiDevTool
  module Controller
    #
    # JCGIのリクエストを行い、レスポンスからビュー表示用データを生成する
    #
    class JcgiOutputController < OutputController
      include Helper::OutputRequest
      include Helper::OutputResponse
      include Helper::OutputParamDisplayData

      #
      # jcgiのリクエストをイントラに発行する
      #   request_url -> リクエストを飛ばすイントラのURL
      #
      def request_jcgi(request_url)
        params = convert_www_form_vars(@request_vars,"utf-8",@encoding)  # リクエスト用にエンコード
        proxys = []
        proxys = ENV['http_proxy'].sub(/\Ahttp:\/\//, '').split(':') if params['val_v2api_dev_tool_need_proxy'] == 'true'
        params = delete_devtool_param(params)
        begin
          #response = Net::HTTP.Proxy(proxys[0], proxys[1]).post_form(URI.parse(request_url),params)
          response = nil
          uri = URI.parse(request_url)
          Net::HTTP.Proxy(proxys[0], proxys[1]).start(uri.host, uri.port){|http|
            header = {
             'Cache-Control' => 'no-cache',
             'Pragma' => 'no-cache'
            }
            array = []
            params.each{|key,value|
              array.push("#{key}=#{value}")
            }
            response = http.post(uri.path, array.join('&'), header)
          }
          response.value  # ステータスコードが200以外の場合、ここで例外発生
        rescue => e
          raise e
        else
          body = response.body
          body.force_encoding(@encoding)  # ASCII-8BIT(バイナリ)として認識されるため、強制エンコード
          @v2_response = convert_jcgi_vars(body,"utf-8")
          return true
        end
      end

      #
      # ビュー表示用データの取得(パラメータデータの取得と変換)
      #
      def get_display_data
        param_data = load_param_data(@api_name,@settings.api_data)
        display_data = generate_display_data(@api_name,param_data,@settings.output_order,@v2_response)
        return display_data
      end
    end
  end
end
