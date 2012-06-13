# -*- coding: utf-8 -*-

require "uri"

module V2apiDevTool
  module Controller
    module Helper
      #
      # outputコントローラで使用するヘルパーメソッド(共通)
      #
      module OutputCommon
        private

        #
        # ハッシュのキー、値をエンコード
        #
        def encode_hash(hash,encoding)
          result = {}
          hash.each do |k,v|
            result[k.encode(encoding)] = v.encode(encoding)
          end
          result
        end

        #
        # URIエンコードされたクエリ文字列をハッシュに分解
        #   src_encoding -> strの文字コード
        #   dst_encoding -> 戻り値(Hash)の文字コード
        #
        def convert_www_form_vars(str,src_encoding,dst_encoding)
          result = URI.decode_www_form(str,src_encoding)
          v2_request = encode_hash(Hash[result],dst_encoding)
          return v2_request
        end

        #
        # jcgiのクエリ文字列をハッシュに分解
        # (マルチバイト文字や"="などの文字がエンコードされていない)
        #   dst_encoding -> 戻り値(Hash)の文字コード
        #
        def convert_jcgi_vars(str,dst_encoding)
          params = str.split("&")
          result = params.map do |param|
            # 最初の"="の前がkey、後ろがvalue(value内の"="はそのまま)
            # "key=hoge=foo" -> ["key","hoge=foo"]
            param.split("=",2)
          end
          v2_request = encode_hash(Hash[result],dst_encoding)
          return v2_request
        end
      end
    end
  end
end
