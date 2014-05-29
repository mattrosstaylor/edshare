function initPreview(eprintid, docid) {
	new Ajax.Request( eprints_http_cgiroot +"/preview_init", {
	  method: "post",
	  parameters:{'id':eprintid},
	  onSuccess: function(response) {
		$('preview_main').innerHTML = response.responseText;
		setPreview(docid);
	  }
	});
}

function setPreview(docid) {
	$('preview_area').setAttribute('src','/cgi/preview?doc='+docid);
	$$('.preview_selected').invoke('removeClassName', 'preview_selected');
	$$('li[id=preview_selector_'+docid+']').invoke('addClassName', 'preview_selected');
	$('preview_document_info').update( $('preview_document_hidden_info_'+docid).innerHTML);
	$('preview_document_button').update( $('preview_document_hidden_button_'+docid).innerHTML);
}

function autoResizePreviewArea(){
	var newheight;
	var newwidth;

	var preview_area = document.getElementById("preview_area");

	newheight = preview_area.contentWindow.document.body.scrollHeight;
	newwidth = preview_area.contentWindow.document.body.scrollWidth;

	preview_area.height = (newheight) + "px";
	preview_area.width = (newwidth) + "px";
}

