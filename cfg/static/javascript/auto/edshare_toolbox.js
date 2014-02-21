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
