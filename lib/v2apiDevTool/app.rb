# -*- coding: utf-8 -*-

require "sinatra/base"
require "erubis"
require_relative "v2api_dev_tool"

module V2apiDevTool
  class V2apiDevToolApp < Sinatra::Base
    # -------- 初期設定 --------
    configure do
      # アプリケーションのメインファイル(同時に:root,:views,:publicが設定される)
      set :app_file, __FILE__

      # erubisのhtmlエスケープ設定
      set :erubis, :escape_html => true

      # 設定ファイルやデータを読み込むクラスのインスタンス化
      config_expand_path    = File.expand_path(File.join(root,"config"))
      view_data_expand_path = File.expand_path(File.join(root,"data/view"))
      api_data_expand_path  = File.expand_path(File.join(root,"data/api"))
      config    = V2apiDevTool::Model::Config.new(config_expand_path)
      view_data = V2apiDevTool::Model::ViewData.new(view_data_expand_path)
      api_data  = V2apiDevTool::Model::ApiData.new(api_data_expand_path)

      # アプリケーションの設定ファイルの読み込み
      set :app_config,       config.load_app_config
      set :app_config_debug, config.exist_app_config_debug? ? config.load_app_config_debug : {}

      # ビューの表示順定義ファイルの読み込み
      set :menu_order,   view_data.load_menu_order
      set :input_order,  view_data.load_input_order
      set :output_order, view_data.load_output_order

      # V2API設定ファイルの読み込み
      set :v2APIs, api_data.load_v2apis
      # データ読み込みオブジェクトをsettingsでアクセス可能に
      set :api_data, api_data
    end

    # -------- ヘルパー登録 --------
    helpers V2apiDevTool::Controller::RoutingHelper
    helpers V2apiDevTool::Controller::ViewHelper

    # -------- ルーティング --------
    # トップページ
    get "/?" do
      erubis :top
    end

    # in/outの指定が無い場合、inputにリダイレクト
    get "/:v2api_name/?" do
      redirect "/#{params[:v2api_name]}/input"
    end

    # パラメータ入力画面
    get "/:v2api_name/input/?" do
      begin
        check_v2api_name(params[:v2api_name])
        controller = V2apiDevTool::Controller::InputController.new(params[:v2api_name],settings)
        display_data = controller.get_display_data
        erubis :input,
               :locals => {v2api_name: params[:v2api_name],
                           display_data: display_data}
      rescue => e
        raise e
      end
    end

    # 実行結果画面
    post "/:v2api_name/output/?" do
      begin
        check_v2api_name(params[:v2api_name])
        request_vars = env["rack.request.form_vars"]
        kind = v2api_kind(params[:v2api_name])
        # リクエストするサーバ
        request_url = params[:val_v2api_dev_tool_request_server] || settings.app_config["v2apiURL"]
        # エンコーディング
        encoding = "cp932"
        if params[:val_encode].is_a?(String) && params[:val_encode] == "utf-8"
          encoding = "utf-8"
        elsif params[:val_out_encode].is_a?(String) && params[:val_out_encode] == "utf-8"
          encoding = "utf-8"
        end

        case kind
        when :jcgi
          controller = V2apiDevTool::Controller::JcgiOutputController.new(params[:v2api_name],request_vars,settings,encoding)
          controller.request_jcgi(request_url)
          display_data = controller.get_display_data
          erubis :output,
                 :locals => {v2api_name: params[:v2api_name],
                             display_data: display_data}
        when :cgi
          if params["val_htmb"]
            # inputからのリクエストの場合、イントラ本体にリクエストするビューを出力
            controller = V2apiDevTool::Controller::CgiRedirectController.new(params[:v2api_name],request_vars,settings,encoding)
            redirect_request = controller.get_redirect_request
            # イントラにリクエストを投げる
            # 文字コードで分岐
            if encoding == "utf-8"
              erubis :cgi_redirect,
                     :layout => false,
                     :locals => {v2_request: redirect_request,
                                 request_url: request_url,
                                 charset: "UTF-8"}
            else
              erubis_cp932 :cgi_redirect,
                           :layout => false,
                           :locals => {v2_request: redirect_request,
                                       request_url: request_url,
                                       charset: "Shift_JIS"}
            end
          else
            # イントラ本体から戻ってきた場合、結果を出力
            controller = V2apiDevTool::Controller::CgiOutputController.new(params[:v2api_name],request_vars,settings,encoding)
            display_data = controller.get_display_data
            erubis :output,
                   :locals => {v2api_name: params[:v2api_name],
                               display_data: display_data}
          end
        end
      rescue => e
        raise e
      end
    end

    # -------- 実行処理 --------
    # このファイル(app.rb)を直接実行した場合、アプリケーション起動
    run! if settings.app_file == $0
  end
end
