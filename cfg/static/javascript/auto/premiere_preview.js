function setPremierePreview(id) {
	$('premiere_preview_area').setAttribute('src','/cgi/premiere_preview?doc='+id);
	$$('.premiere_preview_selected').invoke('removeClassName', 'premiere_preview_selected');
	$$('li[id=premiere_preview_selector_'+id+']').invoke('addClassName', 'premiere_preview_selected');
	$('premiere_preview_document_info').update( $('premiere_preview_document_hidden_info_'+id).innerHTML);
	$('premiere_preview_document_button').update( $('premiere_preview_document_hidden_button_'+id).innerHTML);
}
