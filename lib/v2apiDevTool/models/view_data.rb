# -*- coding: utf-8 -*-

require "yaml"

module V2apiDevTool
  module Model
    class ViewData
      #
      # view_data_expand_path: data/viewディレクトリの絶対パス
      #
      def initialize(view_data_expand_path)
        @view_data_dir = view_data_expand_path

        # 各設定ファイルのパス
        @menu_order_file   = File.join(@view_data_dir,"menu_order.yml")
        @input_order_file  = File.join(@view_data_dir,"input_order.yml")
        @output_order_file = File.join(@view_data_dir,"output_order.yml")
      end

      #
      # menu_orderファイルの読み込み
      #
      def load_menu_order
        File.open(@menu_order_file,"rt:utf-8"){|f|
          YAML.load(f.read)
        }
      end

      #
      # input_orderファイルの読み込み
      #
      def load_input_order
        File.open(@input_order_file,"rt:utf-8"){|f|
          YAML.load(f.read)
        }
      end

      #
      # output_orderファイルの読み込み
      #
      def load_output_order
        File.open(@output_order_file,"rt:utf-8"){|f|
          YAML.load(f.read)
        }
      end
    end
  end
end
