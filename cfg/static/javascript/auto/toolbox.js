/* edshare javascript */
function edshare_render_toolbox(targetId, eprintid) {
	new Ajax.Request( eprints_http_cgiroot +"/edshare_toolbox", {
		method: "post",
		parameters:{'eprintid':eprintid},
		onSuccess: function(response) {
			$(targetId).innerHTML = response.responseText;
	  	}
	});
}

function edshare_suppress_page_title() {
	document.observe( 'dom:loaded', function() {
		$$(".edshare_page_title").each(function(element) {
			element.hide();
		});
	});
}
