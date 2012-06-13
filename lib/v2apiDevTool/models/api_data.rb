# -*- coding: utf-8 -*-

require "yaml"

module V2apiDevTool
  module Model
    class ApiData
      #
      # api_data_expand_path: api_dataディレクトリの絶対パス
      #
      def initialize(api_data_expand_path)
        @api_data_dir = api_data_expand_path

        # ファイルのパス
        @v2apis_file       = File.join(@api_data_dir,"v2APIs.yml")

        # パラメータ設定定義ファイルのあるディレクトリ
        @input_params_dir  = File.join(@api_data_dir,"input_params/")
        @output_params_dir = File.join(@api_data_dir,"output_params/")
      end

      #
      # v2apisファイルの読み込み
      #
      def load_v2apis
        File.open(@v2apis_file,"rt:utf-8"){|f|
          YAML.load(f.read)
        }
      end

      #
      # 入力パラメータ定義ファイルの読み込み
      #   v2api_name: APIの名前
      #
      def load_input_params(v2api_name)
        file_path = File.join(@input_params_dir,"#{v2api_name}_input.yml")
        File.open(file_path,"rt:utf-8"){|f|
          YAML.load(f.read)
        }
      end

      #
      # 出力パラメータ定義ファイルの読み込み
      #   v2api_name: APIの名前
      #
      def load_output_params(v2api_name)
        file_path = File.join(@output_params_dir,"#{v2api_name}_output.yml")
        File.open(file_path,"rt:utf-8"){|f|
          YAML.load(f.read)
        }
      end
    end
  end
end
