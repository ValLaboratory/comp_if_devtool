# -*- coding: utf-8 -*-

require "yaml"

module V2apiDevTool
  module Model
    class Config
      #
      # config_expand_path: configディレクトリの絶対パス
      #
      def initialize(config_expand_path)
        @config_dir = config_expand_path

        # 各設定ファイルのパス
        @app_config_file       = File.join(@config_dir,"app_config.yml")
        @app_config_debug_file = File.join(@config_dir,"app_config_debug.yml")
      end

      #
      # config_debugファイルの存在判定
      #
      def exist_app_config_debug?
        File.exist?(@app_config_debug_file)
      end

      #
      # configファイルの読み込み
      #
      def load_app_config
        File.open(@app_config_file,"rt:utf-8"){|f|
          YAML.load(f.read)
        }
      end

      #
      # config_debugファイルの読み込み
      #
      def load_app_config_debug
        File.open(@app_config_debug_file,"rt:utf-8"){|f|
          YAML.load(f.read)
        }
      end
    end
  end
end
