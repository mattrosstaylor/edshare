function initPremierePreview(eprintid, docid) {
	new Ajax.Request( eprints_http_cgiroot +"/premiere_preview_init", {
	  method: "get",
	  parameters:{'id':eprintid},
	  onSuccess: function(response) {
		$('premiere_preview_main').innerHTML = response.responseText;
		setPremierePreview(docid);
	  }
	});
}

function setPremierePreview(docid) {
	$('premiere_preview_area').setAttribute('src','/cgi/premiere_preview?doc='+docid);
	$$('.premiere_preview_selected').invoke('removeClassName', 'premiere_preview_selected');
	$$('li[id=premiere_preview_selector_'+docid+']').invoke('addClassName', 'premiere_preview_selected');
	$('premiere_preview_document_info').update( $('premiere_preview_document_hidden_info_'+docid).innerHTML);
	$('premiere_preview_document_button').update( $('premiere_preview_document_hidden_button_'+docid).innerHTML);
}
