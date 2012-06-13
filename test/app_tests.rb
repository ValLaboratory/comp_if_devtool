# -*- coding: utf-8 -*-

gem "test-unit"
require 'test/unit'

Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/**/*_test.rb") do |file|
  require file
end

# 以下、中間生成ファイル等を直接出力させるためのコード
#        require "yaml"
#        YAML::ENGINE.yamler = "psych"
#        "<pre>" + YAML::dump(controller.__send__(:convert_www_form_vars,request_vars,"cp932","utf-8")) + "</pre>"
#        require "yaml"
#        YAML::ENGINE.yamler = "psych"
#        "<pre>" + YAML::dump(display_data) + "</pre>"
