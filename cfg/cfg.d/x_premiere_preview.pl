$c->{premiere_preview_width} = 700;
$c->{premiere_preview_height} = 525;


$c->{plugins}{"Convert::OfficePreview"}{params}{disable} = 0;

# enable audio_*/video_* previews
$c->{thumbnail_types} = sub {
	my( $list, $repo, $doc ) = @_;
	push @$list, qw( pdf );
};

$c->{render_premiere_preview_area} = sub
{
	my ( $eprint, $repository ) = @_;
	my $xml = $repository->xml;

	my $div = $xml->create_document_fragment;

	my $first_document = ($eprint->get_all_documents())[0];
	my $docid = $first_document->id;

	my $script = <<EOF;
document.observe('dom:loaded', function(){
	setPremierePreview($docid);
});
EOF

	my $preview_area = $xml->create_element("iframe", id=>"premiere_preview_area", "scrolling"=>"no");
	my $js = $xml->create_element("script", type=>"text/javascript");
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

	my $page = $xml->create_element("div", id=>"premiere_preview_container");

	my $left = $xml->create_element("div", id=>"premiere_preview_left");
	my $right = $xml->create_element("div", id=>"premiere_preview_right");
	# hmmmm, try and find a way to make these divs the correct way around later...
	$page->appendChild($left);
	$page->appendChild($right);

	$left->appendChild( $repository->call("render_premiere_preview_area", $eprint, $repository));
	$left->appendChild( $eprint->render_citation("premiere_preview_document_list"));	
	my $links = $repository->xml->create_document_fragment();
	if( !$preview )
	{
		$links->appendChild( $repository->plugin( "Export::Simple" )->dataobj_to_html_header( $eprint ) );
		$links->appendChild( $repository->plugin( "Export::DC" )->dataobj_to_html_header( $eprint ) );
	}

	# add the main info
		$right->appendChild($eprint->render_citation( "premiere_preview_info" ));

	return( $page, $title, $links );
};

