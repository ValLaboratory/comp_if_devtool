/*==============================================================================
	style.js
	jQuery UIのスタイル用class付加(jQuery必須)
================================================================================*/

$(function(){
	//$("#container").addClass("ui-widget-content");
	$("#header_contents").addClass("ui-widget-content ui-corner-bottom");
	$("#footer_contents").addClass("ui-widget-content ui-corner-top");
	$("th").addClass("ui-widget-header");

	// contents
	$(".group_title_row").addClass("ui-state-hover");
	$(".status_required").addClass("ui-state-highlight");
	$(".status_cond-required").addClass("ui-state-active");

	$(".indent_1").addClass("ui-state-hover");
	$(".indent_2").addClass("ui-state-highlight");
	$(".indent_3").addClass("ui-state-active");
//	$(".indent_3").addClass("ui-state-default");
})
