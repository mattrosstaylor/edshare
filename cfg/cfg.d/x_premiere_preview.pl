$c->{premiere_preview_width} = 640;
$c->{premiere_preview_height} = 480;

$c->{plugins}{"Convert::OfficePreview"}{params}{disable} = 0;

# enable audio_*/video_* previews
$c->{thumbnail_types} = sub {
	my( $list, $repo, $doc ) = @_;
	push @$list, qw( pdf );
};

$c->{render_premiere_preview} = sub
{
	my ( $eprint, $repository ) = @_;
	my $xml = $repository->xml;

	my $div = $xml->create_document_fragment;
	my $w = $repository->get_conf("premiere_preview_width");
	my $h = $repository->get_conf("premiere_preview_height");

	my $first_document = ($eprint->get_all_documents())[0];
	my $docid = $first_document->id;

	my $script = <<EOF;
document.observe('dom:loaded', function(){
	setPremierePreview($docid);
});
EOF


	my $preview_area = $xml->create_element("iframe", "id"=>"premiere_preview_area", "style"=>"width:".$w."px;height:".$h."px;", "scrolling"=>"no");
	my $js = $xml->create_element("script", "type"=>"text/javascript");
	$js->appendChild($xml->create_text_node($script));
	$div->appendChild($preview_area);
	$div->appendChild($js);
	return $div;
};

$c->{eprint_render} = sub
{
	my ( $eprint, $repository, $preview ) = @_;

	my $xml = $repository->xml;
	my $title = $eprint->render_citation("brief");
	#my $title = $xml->create_document_fragment;

	my $page = $xml->create_element("div");

	# replace this if they every 
	my $naughty_css_hack = $xml->create_element("style", type=>"text/css");
	$naughty_css_hack->appendChild( $xml->create_text_node(".ep_tm_pagetitle { display: none; }"));
	$page->appendChild($naughty_css_hack);

	my $p = $repository->call("render_premiere_preview", $eprint, $repository);
	my $d = $eprint->render_citation("premiere_preview_documents");
	
	# hmmmm, try and find a way to make these divs the correct way around later...
	$page->appendChild($d);
	$page->appendChild($p);

	my $links = $repository->xml->create_document_fragment();
	if( !$preview )
	{
		$links->appendChild( $repository->plugin( "Export::Simple" )->dataobj_to_html_header( $eprint ) );
		$links->appendChild( $repository->plugin( "Export::DC" )->dataobj_to_html_header( $eprint ) );
	}

	# add the main info
	$page->appendChild($eprint->render_citation( "premiere_preview_info" ));

	return( $page, $title, $links );
};


