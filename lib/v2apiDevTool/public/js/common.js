/*==============================================================================
	common.js
	共通スクリプト(jQueryおよびjQuery UI必須)
	インクリメンタルサーチ割り当て(IncSearch())には、
	駅名検索リクエスト先のjsenvおよびIncrementalSearch.js必須
================================================================================*/

$(function(){
	var apiName = $("#input_param_table input[name=val_htmb]").val();

	var header = new HeaderMenu();
	header.init();

	var inputParamForm = new InputParamForm(apiName,10);
	inputParamForm.initSubmit();
	inputParamForm.initInputQuery();
	inputParamForm.initUserParam();
	inputParamForm.historyDialog();
	inputParamForm.setTabIndex();
	inputParamForm.initRequestServer();

	var incSearch = new IncSearch();
	incSearch.bind();

	bindScrollAnimation();
	bindUIButtonAll();

	// ヘッダは描画スタイルが全て適用されてから表示
	$("#header").css("visibility","visible");
});

//===============================================================================
// $function        : ヘッダメニューのドロップダウンメニュー関連のイベント
// $functionName    : HeaderMenu()
// $inParam         : なし
// $outParam        : なし
//===============================================================================
function HeaderMenu(){
	this.init = function(){
		setUIStyleEvent();
		fixMenuPosition();
		setMenuEvent();
	}

	// jQuery UIのスタイル用クラス制御
	var setUIStyleEvent = function(){
		$(".api_menu_item").addClass("ui-widget ui-state-default ui-corner-all");
		$(".api_menu_item").hover(function(){
			$(this).toggleClass("ui-state-default ui-state-hover");
		},function(){
			$(this).toggleClass("ui-state-default ui-state-hover");
		});
		$(".api_menu_item.api_menu_name").mousedown(function(){
			$(this).addClass("ui-state-active ui-state-focus");
		});
		$(".api_menu_item.api_menu_name").mouseup(function(){
			$(this).removeClass("ui-state-active ui-state-focus");
		});
		$(".api_menu_item.api_menu_name").mouseout(function(){
			$(this).removeClass("ui-state-active ui-state-focus");
		});
	}

	// 小メニューの位置調整
	var fixMenuPosition = function(){
		// 右側のはみ出さない限界位置
		var $headerContents = $("#header_contents");
		var rightLimit = $headerContents.offset().left + $headerContents.outerWidth();
		// 2層目のメニュー位置を先に確定
		$(".api_menu_list.api_menu_comment").each(function(){
			var $liChild = $(this).children(".api_menu_item");
			var liChildRight = $liChild.offset().left + $liChild.outerWidth();
			if(liChildRight > rightLimit){
				var liParentWidth = $(this).parent(".api_menu_item").width();
				var liChildWidth = $liChild.width();
				$(this).css({"left": "auto", "right": liChildWidth - liParentWidth});
			}
		});
		// 2層目が確定しているので3層目
		$(".api_menu_list.api_menu_name").each(function(){
			var $liChild = $(this).children(".api_menu_item");
			var liChildRight = $liChild.offset().left + $liChild.outerWidth();
			if(liChildRight > rightLimit){
				var liChildWidth = $liChild.width();
				$(this).css({"left": "auto", "right": liChildWidth + 2});
			}
		});
	};

	// メニュー操作時のイベント
	var setMenuEvent = function(){
		// 最初に子要素を隠す
		// 深い要素からhideしないとIE7で適用されないので順番に処理
		$(".api_menu_list.api_menu_name").hide();
		$(".api_menu_list.api_menu_comment").hide();

		// メニュー開閉動作
		$(".api_menu_item").hover(function(){
			$(">.api_menu_list:not(:animated)",this).show();
		},function(){
			$(">.api_menu_list",this).hide();
		});

		// ダミーURLの場合、遷移イベントカット
		$(".api_menu_list a").click(function(){
			if($(this).attr("href") == "#"){
				return false;
			}
		})
	};
}

//===============================================================================
// $function        : 入力パラメータフォーム関連
// $functionName    : InputParamForm()
// $inParam         : apiName  APIの名称
// $outParam        : なし
//===============================================================================
function InputParamForm(apiName,maxHistory){
	var requestServer = new RequestServer();
	var userParam = new UserParam();

	var historyStorage = null;
	var lastRequestServerStorage = null;
	// WebStorageおよびjsのJSONオブジェクト対応の場合のみオブジェクト生成
	if(window.sessionStorage != undefined && typeof JSON != "undefined"){
		historyStorage = new HistoryStorage(maxHistory);
		lastRequestServerStorage = new LastRequestServerStorage();
	}

	//===============================================================================
	// $function        : リクエストサーバ関連イベントの初期化
	// $functionName    : initRequestServer()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	this.initRequestServer = function(){
		requestServer.init();
	}

	//===============================================================================
	// $function        : リクエストサーバ指定機能操作クラス
	// $functionName    : RequestServer()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	function RequestServer(){
		var defaultText = "URLを直接指定(例：\"http://intra.val.co.jp/expwww2_20120201/expcgi.exe\")";
		var textBoxDefault = new TextBoxDefault("#input_request_server",defaultText);
		var selectServerURLs = $("#select_request_server option").map(function(){
			return $(this).val();
		}).get();

		//===============================================================================
		// $function        : イベントの初期化
		// $functionName    : init()
		// $inParam         : なし
		// $outParam        : なし
		//===============================================================================
		this.init = function(){
			// 値が無い場合の初期値を設定
			textBoxDefault.init();

			// 前回のリクエスト先を取得し、反映する
			// lastRequestServerStorageが有効な場合のみ
			var url = null
			if(lastRequestServerStorage != null){
				url = lastRequestServerStorage.getLastRequestServerURL();
			}
			if(url != null){
				setServerURL(url);
			}

			// セレクトボックス変更時に、テキストボックスの内容を消去する
			$("#select_request_server").change(function(){
				textBoxDefault.clearTextBox();
			});

			// テキストボックスの内容を消去するボタンのイベント割り当て
			$("#clear_input_request_server_button").click(function(){
				textBoxDefault.clearTextBox();
			})
		};

		//===============================================================================
		// $function        : 現在リクエスト送信対象になっているサーバのURLを取得
		//                    優先順位は以下の通り
		//                      1. テキストボックス(#input_request_server)
		//                      2. セレクトボックス(#select_request_server)
		//                      3. hidden要素(デフォルト)(#static_request_server)
		//                    テキストボックスに不正なURLが入っている場合でも直接返すので、
		//                    別途確認すること
		// $functionName    : getServerURL()
		// $inParam         : なし
		// $outParam        : URL
		//===============================================================================
		this.getServerURL = function(){
			// テキストボックスが存在し、値があれば返す
			var $inputRequest = $("#input_request_server");
			if(($inputRequest.length == 1) &&
			   (!($inputRequest.hasClass("no_value")))){
				return $inputRequest.val();
			}

			// セレクトボックスが存在すれば、値を返す
			var $selectRequest = $("#select_request_server");
			if($selectRequest.length == 1){
				return $selectRequest.val();
			}

			// デフォルトの値を返す
			return $("#static_request_server").val();
		};

		//===============================================================================
		// $function        : リクエスト送信対象のサーバのURLを設定する
		// $functionName    : setServerURL()
		// $inParam         : url  設定するURL
		// $outParam        : なし
		//===============================================================================
		this.setServerURL = function(url){
			// セレクトボックス内に値があればそれを設定し、テキストボックスの内容を削除する
			if(jQuery.inArray(url,selectServerURLs) != -1){
				$("#select_request_server").val(url);
				textBoxDefault.clearTextBox();  // no_valueクラスの制御が必要
			}
			// なければ、テキストボックスに適用
			else{
				textBoxDefault.setTextBox(url);
			}
		};
		var setServerURL = this.setServerURL;

		//===============================================================================
		// $function        : イントラのURLとして正しいかを判定
		// $functionName    : isValidURL()
		// $inParam         : url  チェックするURL
		// $outParam        : true/false
		//===============================================================================
		this.isValidURL = function(url){
			// URLとして正しい + 末尾がexpcgi.exeまたはexp.cgi
			var urlRegexp = /^https?:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+(expcgi.exe|exp.cgi)$/;
			return urlRegexp.test(url);
		};

		//===============================================================================
		// $function        : テキストボックスの内容を消去するボタン
		// $functionName    : clearTextBoxButton()
		// $inParam         : なし
		// $outParam        : なし
		//===============================================================================
		var clearTextBoxButton = function(){
			$("#clear_input_request_server_button").click(function(){
				textBoxDefault.clearTextBox();
			})
		}
	}

	//===============================================================================
	// $function        : 履歴データ操作クラス
	// $functionName    : History()
	// $inParam         : maxHistory  1つのAPIにつき保持する履歴の最大値
	// $outParam        : なし
	//===============================================================================
	function HistoryStorage(maxHistory){

		//===============================================================================
		// $function        : WebStorage(settion)から、履歴データの読み込み
		// $functionName    : getHistory()
		// $inParam         : なし         
		// $outParam        : apiHistoryData  履歴データ
		//===============================================================================
		this.getHistory = function(){
			var storageString = sessionStorage["v2apiDevTool_history"];
			var storageData = {}
			if(storageString && typeof JSON != "undefined"){
				storageData = JSON.parse(storageString);
			}
			var apiHistoryData = storageData[apiName] || [];

			return apiHistoryData;
		}

		//===============================================================================
		// $function        : WebStorage(settion)へ、履歴データの書き込み
		// $functionName    : setHistory()
		// $inParam         : serverURL   リクエストするイントラサーバのURL
		//                  : queryHash   入力パラメータのハッシュ
		// $outParam        : なし
		//===============================================================================
		this.setHistory = function(serverURL,queryHash){
			var storageString = sessionStorage["v2apiDevTool_history"];
			var storageData = {};
			if(storageString && typeof JSON != "undefined"){
				storageData = JSON.parse(storageString);
			}
			var apiHistoryData = storageData[apiName] || [];

			// (最大数-1)個だけ取り出す
			apiHistoryData = apiHistoryData.slice(0,maxHistory - 1);
			// 頭に追加
			apiHistoryData.unshift({
				server: serverURL,
				query: queryHash
			});

			storageData[apiName] = apiHistoryData;
			if(typeof JSON != "undefined"){
				sessionStorage["v2apiDevTool_history"] = JSON.stringify(storageData);
			}
		}
	}

	//===============================================================================
	// $function        : 直近リクエスト先データ操作クラス
	// $functionName    : LastRequestServerStorage()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	function LastRequestServerStorage(){

		//===============================================================================
		// $function        : WebStorage(settion)から、履歴データの読み込み
		// $functionName    : getLastRequestServerURL()
		// $inParam         : なし
		// $outParam        : serverURL  最後にリクエストをしたサーバのURL
		//===============================================================================
		this.getLastRequestServerURL = function(){
			var url = sessionStorage["v2apiDevTool_lastRequestServer"];
			var serverURL = url || null;

			return serverURL;
		}

		//===============================================================================
		// $function        : WebStorage(settion)へ、履歴データの書き込み
		// $functionName    : setLastRequestServerUrl()
		// $inParam         : serverURL   リクエストするイントラサーバのURL
		// $outParam        : なし
		//===============================================================================
		this.setLastRequestServerURL = function(serverURL){
			sessionStorage["v2apiDevTool_lastRequestServer"] = serverURL;
		}
	}

	//===============================================================================
	// $function        : ユーザーパラメータイベントの割り当て
	// $functionName    : initUserParam()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	this.initUserParam = function(){
		userParam.init();
	}

	//===============================================================================
	// $function        : ユーザーパラメータ操作クラス
	// $functionName    : UserParam()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	function UserParam(){

		//===============================================================================
		// $function        : ユーザーパラメータ入力フォームイベントの初期化
		// $functionName    : init()
		// $inParam         : なし
		// $outParam        : なし
		//===============================================================================
		this.init = function(){
			bindAddFormButton($(".user_param_addition_button"));
		};

		//===============================================================================
		// $function        : ユーザーパラメータ入力行を追加
		// $functionName    : appendUserParamRow()
		// $inParam         : key        ユーザーパラメータのパラメータ名
		//                    value      ユーザーパラメータの値
		// $outParam        : $paramRow  追加した行のjQueryオブジェクト
		//                               失敗した場合(追加ボタンの行が無い場合)はnull
		//===============================================================================
		this.appendUserParamRow = function(key,value){
			if(key === undefined) key = "";
			if(value === undefined) value = "";
			// ユーザーパラメータ入力フォーム、tableの1行分に相当
			var userParamHtml = '<tr class="user_param">' +
								'  <td class="name_col">' +
								'    <input type="text" class="user_param_name" value="' + key + '" />' + 
								'  </td>' +
								'  <td class="value_col">' +
								'    <input type="text" class="user_param_value" value="' + value + '" />' + 
								'  </td>' +
								'  <td class="comment_col">' +
								'    ユーザーパラメータ' +
								'<span class="user_param_controll"><input type="button" class="user_param_delete_button" value="削除" /></span>' +
								'  </td>' +
								'</tr>';

			// 追加ボタンの行の手前に追加
			var $additionButtonRow = $(".user_param_addition")
			// 追加ボタンが無い場合、nullを返す
			if($additionButtonRow.length == 0){
				return null;
			}
			$additionButtonRow.before(userParamHtml);

			// 追加した行のjQueryオブジェクト取得
			var $paramRow = $additionButtonRow.prev(".user_param");

			// 削除ボタンイベント割り当て
			var $paramDeleteButton = $paramRow.find(".user_param_delete_button");
			$paramDeleteButton.button();  // jQuery UI button
			bindDeleteFormButton($paramDeleteButton);

			return $paramRow
		};
		var appendUserParamRow = this.appendUserParamRow;

		//===============================================================================
		// $function        : ユーザーパラメータ入力行を削除
		// $functionName    : deleteUserParamRow()
		// $inParam         : $paramRow  削除する行のjQueryオブジェクト
		//                    与えられない場合、全てのユーザーパラメータ行を削除する
		// $outParam        : なし
		//===============================================================================
		this.deleteUserParamRow = function($paramRow){
			if($paramRow === undefined){
				$(".user_param").remove();
			}
			// ユーザーパラメータ行でない場合は無視
			else if($paramRow.hasClass("user_param")){
				$paramRow.remove();
			}
		}
		var deleteUserParamRow = this.deleteUserParamRow;

		//===============================================================================
		// $function        : ユーザーパラメータ追加ボタンのイベント割り当て
		// $functionName    : bindAddFormButton()
		// $inParam         : $buttonObj  ボタンのjQueryオブジェクト
		// $outParam        : なし
		//===============================================================================
		var bindAddFormButton = function($buttonObj){
			$buttonObj.click(function(){
				// ユーザーパラメータ行追加
				var $paramRow = appendUserParamRow();

				// 追加された行までスクロール
				var offsetTop = $paramRow.offset().top;
				$("html,body").scrollTop(offsetTop);
			});
		};

		//===============================================================================
		// $function        : ユーザーパラメータ行削除ボタンのイベント割り当て
		// $functionName    : bindDeleteFormButton()
		// $inParam         : $buttonObj  ボタンのjQueryオブジェクト
		// $outParam        : なし
		//===============================================================================
		var bindDeleteFormButton = function($buttonObj){
			$buttonObj.click(function(){
				deleteUserParamRow($(this).parents(".user_param"));
			});
		};
	}

	//===============================================================================
	// $function        : テキストボックスが空の時に表示する文字の制御クラス
	// $functionName    : TextBoxDefault()
	// $inParam         : selector     対象テキストボックスのセレクタ
	//                    defaultText  デフォルト表示用テキスト
	// $outParam        : なし
	//===============================================================================
	function TextBoxDefault(selector,defaultValue){

		//===============================================================================
		// $function        : テキストボックスに対して、値が入っていない場合に
		//                    デフォルトの文字列を表示させる
		//                    値が入っていない場合には、no_valueクラスが付加される
		// $functionName    : init()
		// $inParam         : なし
		// $outParam        : なし
		//===============================================================================
		this.init = function(){
			// テキストボックスの初期値
			$(selector).addClass("no_value").val(defaultValue);

			// テキストボックスに文字が入っていなければ、defaultValueを表示させる
			$(selector).focus(function(){
				if($(this).hasClass("no_value")){
					$(this).val("");
					$(this).removeClass("no_value");
					// setTextBox(""); これ使うとno_valueが外れないので直接
				}
			}).blur(function(){
				if($(this).val() == ""){
					clearTextBox();
				}
			});
		};

		//===============================================================================
		// $function        : テキストボックスに値を設定する
		//                    このとき、空欄状態を示すクラスを削除する
		// $functionName    : setTextBox()
		// $inParam         : value  設定する値
		// $outParam        : なし
		//===============================================================================
		var setTextBox = function(value){
			if(value != ""){
				$(selector).val(value);
				$(selector).removeClass("no_value");
			}
		};
		this.setTextBox = setTextBox;

		//===============================================================================
		// $function        : テキストボックスの内容を消去する
		//                    このとき、空欄時の文字列とクラスを設定する
		// $functionName    : clearTextBox()
		// $inParam         : なし
		// $outParam        : なし
		//===============================================================================
		var clearTextBox = function(){
			$(selector).val(defaultValue);
			$(selector).addClass("no_value");
		};
		this.clearTextBox = clearTextBox;
	}

	//===============================================================================
	// $function        : パラメータ送信formのsubmitイベント
	//                    table内のinput要素の内容をhiddenで追加する
	//                    ユーザーパラメータも、キーの存在するものについては追加する
	//                    また、利用するサーバのURLを、他の入力パラメータと一緒にsubmitする
	//                    さらに、履歴を追加する
	// $functionName    : initSubmit()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	this.initSubmit = function(){
		$("#input_param_form").submit(function(){
			var server = requestServer.getServerURL();
			// サーバURLチェック
			// 正しくない場合、submit中止
			if(!requestServer.isValidURL(server)){
				alert("サーバのURLが不正です");
				return false
			}

			var inputTextQuery = {};
			var inputHiddenQuery = {};
			var inputUserParamQuery = {};

			var isUserParamError = false;
			var userParamErrorVal = [];
			var userParamErrorNotAscii = [];

			// input要素からnameとvalueを抽出しまとめる
			$(".api_input_param:text").each(function(){
				var name = $(this).attr("name");
				var value = $(this).val();
				if(value){
					inputTextQuery[name] = value;
				}
			});
			$(".api_input_param:hidden").each(function(){
				var name = $(this).attr("name");
				var value = $(this).val();
				if(value){
					inputHiddenQuery[name] = value;
				}
			});
			$(".user_param").each(function(){
				var name = $(this).find(".user_param_name").val();
				var value = $(this).find(".user_param_value").val();
				// val付きパラメータの場合、エラー
				// if(name.match(/^val_/)){
				// 	userParamErrorVal.push(name);
				// 	isUserParamError = true;
				// }
				// パラメータ名称にマルチバイト文字を含む場合、エラー
				// else 
				if(isIncludeNotAsciiChar(name)){
					userParamErrorNotAscii.push(name);
					isUserParamError = true;
				}
				// それ以外で名称がある場合、正常処理
				else if(name){
					inputUserParamQuery[name] = value;
				}
			});

			// エラーチェック
			// エラーがある場合、submit中止
			if(isUserParamError){
				var alertText = "";
				if(userParamErrorVal.length > 0){
					alertText += "以下のユーザーパラメータは、「val_」から始まる名称のため指定できません。\n"
					for(var i = 0; i < userParamErrorVal.length; i++){
						alertText += "「" + userParamErrorVal[i] + "」\n";
					}
					alertText += "\n";	
				}
				if(userParamErrorNotAscii.length > 0){
					alertText += "以下のユーザーパラメータは、ASCII文字以外の文字を含む名称のため指定できません。\n"
					for(var i = 0; i < userParamErrorNotAscii.length; i++){
						alertText += "「" + userParamErrorNotAscii[i] + "」\n";
					}
				}
				alert(alertText);
				return false;
			}

			// hiddenとしてformに要素追加 & 履歴に追加するパラメータの抽出(hidden以外が対象)
			var historyQuery = {};
			var inputName;
			for(inputName in inputTextQuery){
				$(this).append("<input type='hidden' name='" + inputName + "' value='" + inputTextQuery[inputName] + "' />");
				historyQuery[inputName] = inputTextQuery[inputName];
			}
			for(inputName in inputHiddenQuery){
				$(this).append("<input type='hidden' name='" + inputName + "' value='" + inputHiddenQuery[inputName] + "' />");
			}
			for(inputName in inputUserParamQuery){
				$(this).append("<input type='hidden' name='" + inputName + "' value='" + inputUserParamQuery[inputName] + "' />");
				historyQuery[inputName] = inputUserParamQuery[inputName];
			}

			// 履歴追加(テキストボックスに入力されたパラメータ、およびユーザーパラメータを追加)
			// 最後に実行した履歴と同一の場合、追加しない
			// historyStorage未使用の場合は無視
			if(historyStorage != null){
				var historyData = historyStorage.getHistory();
				var historyLastServer = "";
				var historyLastQuery = {};
				if(historyData.length > 0){
					historyLastServer = historyData[0]["server"];
					historyLastQuery = historyData[0]["query"];
				}
				if((historyData.length == 0) || 
				   (server != historyLastServer) ||
				   (!isEqualStringHash(historyQuery,historyLastQuery))){
					historyStorage.setHistory(server,historyQuery);
				}
			}
			// 利用サーバURLをinput要素として追加
			$(this).append("<input type='hidden' name='val_v2api_dev_tool_request_server' value='" + server + "' />");
			// proxyがチェックされていたらフラグパラメータを渡す
			// 利用サーバURLをWebStorageに保存
			// lastRequestServerStorage未使用の場合は無視
			if(lastRequestServerStorage != null){
				lastRequestServerStorage.setLastRequestServerURL(server);
			}
                        if ($('#input_need_proxy').attr('checked')) {
                            $(this).append("<input type='hidden' name='val_v2api_dev_tool_need_proxy' value='true' />");
                        }
		});
	};

	//===============================================================================
	// $function        : 実行履歴関連イベントの追加
	// $functionName    : historyDialog()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	this.historyDialog = function(){
		// historyStorage未使用の場合、履歴表示ボタンを削除して終了
		if(historyStorage == null){
			$(".view_history").remove();
			return;
		}

		// jQuery UI Dialog初期化
		var $historyDialog = $('<div id="history_dialog">');
		$("body").append($historyDialog);
		$historyDialog.dialog({
			autoOpen: false,
			title: "実行履歴",
			buttons: {
				"閉じる": function(){$(this).dialog("close");}
			}
		});

		var apiHistoryData = historyStorage.getHistory();	// 履歴データの読み込み
		if(apiHistoryData.length == 0){
			$historyDialog.append("<p>実行履歴はありません。</p>");
		}
		else{
			// 履歴リストの構築、追加
			var $historyList = $('<ol id="history_list">');
			// リスト構築
			for(var i=0;i < apiHistoryData.length;i++){
				var queryData = apiHistoryData[i]["query"];

				// GET形式のリクエストURL生成(val_cgi_urlは省略される)
				var requestURL = apiHistoryData[i]["server"];
				requestURL += "?val_htmb=" + apiName;
				for(var key in queryData){
					requestURL += "&" + key + "=" + queryData[key];
				}
				var urlParagraphHtml = "<p>" + requestURL + "</p>";

				// idに番号を振って識別子にする
				var historyItemAssignHtml = '<button type="button" id="history_item_assign_' + i + '" class="history_item_assign">適用</button>';
				var historyItemHtml = '<li id="history_item_' + i + '" class="history_item">' + urlParagraphHtml + historyItemAssignHtml + '</li>';
				$historyList.append(historyItemHtml);
			}
			$historyDialog.append($historyList);

			// ボタンのイベント設定
			$(".history_item_assign").click(function(){
				// 末尾の数字部分を抜き出す
				var idNo = $(this).attr("id").replace("history_item_assign_","");
				// 対応する履歴URLのクエリ文字列と実行サーバを取得
				var urlText = $("#history_item_" + idNo + " p").text();
				var queryString = urlText.replace(/.+?val_htmb=[^&]+&?/,"");
				var server = urlText.replace(/\?.+/,"");
				// クエリ文字列の適用
				assignQueryString(queryString);
				// サーバ選択用セレクトボックスの変更、またはテキストボックスへの反映
				requestServer.setServerURL(server);

				$historyDialog.dialog("close");
			});
		}

		// ダイアログ表示イベント
		$(".view_history").click(function(){
			$historyDialog.dialog("option",{
				minWidth: 700,
				maxWidth: 700,
				height: 450,
				maxHeight: $(window).height() - $("#header").height() - $("#footer").height()
			})
			$historyDialog.dialog("open");
		});
	};

	//===============================================================================
	// $function        : パラメータ代入機能
	// $functionName    : initInputQuery()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	this.initInputQuery = function(){
		var defaultText = "パラメータ代入(例：\"val_from=東京&val_to=大阪\")"

		// 値が無い場合の初期値を設定
		var textBoxDefault = new TextBoxDefault("#input_query",defaultText)
		textBoxDefault.init();

		// 代入ボタンを押すとクエリ文字列をフォームにセット
		$("#input_query_button").click(function(){
			// 値が無い場合は何もしない
			if(!$("#input_query").hasClass("no_value")){
				assignQueryString($("#input_query").val());
			}
		});
	}

	//===============================================================================
	// $function        : パラメータ入力テキストボックスにtabindexを割り振る
	// $functionName    : setTabIndex()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	this.setTabIndex = function(){
		$(".api_input_param:text").each(function(i){
			$(this).attr("tabindex",i+1);
		});
	}

	//===============================================================================
	// $function        : パラメータを該当するテキストボックスに代入
	//                    valなしパラメータの場合、ユーザーパラメータとして追加
	// $functionName    : assignQueryString()
	// $inParam         : queryString  GET形式のパラメータ文字列
	// $outParam        : なし
	//===============================================================================
	var assignQueryString = function(queryString){
		// 何も与えられない場合、初期化して終了
		if(queryString.length == 0){
			clearForm();
			return;
		}

		// 初期化
		clearForm();
		var notFoundParams = [];
		var noValueParams = [];

		// 分解
		var queryArray = queryString.split("&");

		// 適用
		for(var i = 0; i < queryArray.length; i++){
			var key_value = queryArray[i].split("=");

			// 要素取得
			var $textElements = $(":text[name=" + key_value[0] +"]:not([disabled])");
			// エラー判定
			if($textElements.length == 0){
				// 存在しなければユーザーパラメータ枠に代入する
			    // ユーザーパラメータ行追加
				var $obj = userParam.appendUserParamRow(key_value[0],key_value[1]);
				if($obj == null){
					// 追加できなかった場合、存在しなかった入力パラメータとして記録
					notFoundParams.push(key_value[0]);
					continue;
				}
			}
			if(key_value[1] == "" || key_value[1] === undefined){
				noValueParams.push(key_value[0]);
				continue;
			}
			// 代入
			$textElements.val(key_value[1]);
		}

		// 入力できなかったパラメータの通知
		if(notFoundParams.length > 0 || noValueParams.length > 0){
			var alertText = "";
			if(notFoundParams.length > 0){
				alertText += "以下のパラメータは代入できません\n";
				for(var i = 0; i < notFoundParams.length; i++){
					alertText += "「" + notFoundParams[i] + "」\n";
				}
				alertText += "\n";
			}
			if(noValueParams.length > 0){
				alertText += "以下のパラメータは値がありません\n";
				for(var i = 0; i < noValueParams.length; i++){
					alertText += "「" + noValueParams[i] + "」\n";
				}
			}
			alert(alertText);
		}
	};

	//===============================================================================
	// $function        : 全inputフォームのvalueを削除する
	//                    また、ユーザーパラメータ行を全て削除する
	// $functionName    : clearForm()
	// $inParam         : なし
	// $outParam        : なし
	//===============================================================================
	var clearForm = function(){
		$(".api_input_param:text:not([disabled])").val("");
		userParam.deleteUserParamRow();
	};

	//===============================================================================
	// $function        : ascii文字(制御文字は除く)以外の文字が含まれるかを判定
	// $functionName    : isIncludeNotAsciiChar()
	// $inParam         : str  判定する文字列
	// $outParam        : true/false
	//===============================================================================
	var isIncludeNotAsciiChar = function(str){
		for(var i=0;i<str.length;i++){
			var c = str.charCodeAt(i);
			// 制御文字は除き、スペースは含む
			if(!(c >= 0x20 && c <= 0x7e)){
				return true;
			}
		}
		return false;
	}

	//===============================================================================
	// $function        : 2つのハッシュが同一の内容であるかを判定
	//                    各キーの値がStringであることが前提
	// $functionName    : isEqualStringHash()
	// $inParam         : hash1
	//                    hash2
	// $outParam        : true/false
	//===============================================================================
	var isEqualStringHash = function(hash1,hash2){
		// キーを配列に抽出
		var hashKey1 = [];
		var hashKey2 = [];
		var key;
		for(key in hash1){
			hashKey1.push(key);
		}
		for(key in hash2){
			hashKey2.push(key);
		}

		// ソート
		hashKey1.sort()
		hashKey2.sort()
		// 文字列化
		var hashKeyStr1 = hashKey1.sort().toString();
		var hashKeyStr2 = hashKey2.sort().toString();

		// 一致しない場合、ハッシュは不一致
		if(hashKeyStr1 != hashKeyStr2) return false;

		// キーの一致判定
		for(var i=0;i<hashKey1.length;i++){
			if(hash1[hashKey1[i]] != hash2[hashKey1[i]]){
				return false;
			}
		}
		return true;
	}
}

//===============================================================================
// $function        : インクリメンタルサーチの割り当て
//                    駅名検索リクエスト先のjsenvおよびIncrementalSearch.js必須
// $functionName    : IncSearch()
// $inParam         : なし
// $outParam        : なし
//===============================================================================
function IncSearch(){
	this.bind = function(){
		// テキストボックスを監視するエージェント
		var incSearchAgents = [];

		$(".incsearch_input").each(function(i){
			var $inputBox = $(this);
			var $resultDiv = $(this).nextAll(".incsearch_result");
			// id設定
			var idInput = "incsearch_input_" + i;
			var idResult = "incsearch_result_" + i;
			$inputBox.attr("id",idInput);
			$resultDiv.attr("id",idResult);

			// インクリメンタルサーチ設定
			var agent = new valV2API.station.IncrementalSearch(idInput,idResult);
			agent.setListViewSize(30);
			agent.addCallbackAfterDecide(function(){
				$inputBox.parents("tr").next("tr").find(":text").focus();
			});
			agent.addCallbackBeforeShow(function(){
				$resultDiv.css("display","block");
			});
			agent.addCallbackAfterHide(function(){
				$resultDiv.css("display","none");
			});
			agent.setBackGround("#ffffff");
			agent.agentStart();
			incSearchAgents.push(agent);
		});
	};
}

//===============================================================================
// $function        : jQuery UIのButtonを、
//                    全てのbuttonまたはsubmit要素に適用(inputタグ、buttonタグ両方)
// $functionName    : bindUIButtonAll()
// $inParam         : selector  適用するボタンのセレクタ
// $outParam        : なし
//===============================================================================
function bindUIButtonAll(){
	$(":button, :submit").button();
/*
	$("#input_query_button").button();  // パラメータ代入ボタン
	$(".view_history").button();  // 履歴ボタン
	$(".history_item_assign").button();  // 履歴ダイアログ内の履歴適用ボタン
	$("#input_param_form :submit").button();  // 送信(実行)ボタン
*/
}


//===============================================================================
// $function        : #付きアンカーのクリック時にスクロールするアニメーションを追加する
//                    (#contents_outputと#footerの子孫要素にのみ適用)
//                    (#headerにはメニューの操作と競合するため適用しない)
// $functionName    : bindScrollAnimation()
// $inParam         : なし
// $outParam        : なし
//===============================================================================
function bindScrollAnimation(){
	$("#contents_output a[href^=#], #footer a[href^=#]").click(function(){
		var fragment = $(this).attr("href")
		var paddingTop = 0;

		var fragOffset = 0;  // "#"のみの場合は一番上に移動
		// それ以外の場合、ヘッダ部分のpaddingを考慮した位置に移動
		if(fragment != "#"){
			paddingTop = $("#contents_input").css("padding-top");
			if(paddingTop === undefined){
				paddingTop = $("#contents_output").css("padding-top");
			}
			paddingTop = parseInt(paddingTop.replace("px",""));
			fragOffset = $(fragment).offset().top - paddingTop;
		}

		$("html:not(:animated), body:not(:animated)").animate({
			scrollTop: fragOffset
		});
		return false;
	});
}
