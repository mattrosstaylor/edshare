function setPremierePreview(id) {
	$('premiere_preview_area').setAttribute('src','/cgi/preview?doc='+id);
	$$('.premiere_preview_selected').invoke('removeClassName', 'premiere_preview_selected');
	$$('li[id=premiere_preview_selector_'+id+']').invoke('addClassName', 'premiere_preview_selected');
}
