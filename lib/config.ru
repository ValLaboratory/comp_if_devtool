require File.expand_path(File.dirname(__FILE__)) + "/v2apiDevTool/app"

map "/v2apiDevTool" do
  run V2apiDevTool::V2apiDevToolApp
end
