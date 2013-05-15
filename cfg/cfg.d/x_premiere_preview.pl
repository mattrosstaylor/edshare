$c->{premiere_preview_width} = 640;
$c->{premiere_preview_height} = 480;


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

$c->{render_premiere_preview_documents} = sub
{
	my ( $eprint, $repository ) = @_;
	my $xml = $repository->xml;

	my $panel = $xml->create_document_fragment();

	# document count
	my $header_div = $xml->create_element("div", class=>"premiere_preview_right_bar premiere_preview_right_header");
	my $header_span = $xml->create_element("span");
	$header_div->appendChild($header_span);
	$panel->appendChild($header_div);

	my $document_count = scalar($eprint->get_all_documents());
	

	if ($document_count eq 1)
	{
		$header_span->appendChild($repository->html_phrase("premiere_preview_document_count_one"));
	}
	else
	{
		$header_span->appendChild(
			$xml->create_text_node(
				$repository->phrase("premiere_preview_document_count", count=>$document_count)
			)
		);
	}
	
	# document list
	my $document_list_div = $xml->create_element("div", class=>"premiere_preview_document_area");
	my $document_list = $xml->create_element("ol", class=>"premiere_preview_document_list");
	$document_list_div->appendChild($document_list);
	$panel->appendChild($document_list_div);
	
	foreach ($eprint->get_all_documents())
	{
		$document_list->appendChild($_->render_citation("premiere_preview_selector"));
	}

	# footer
	my $footer_div = $xml->create_element("div", class=>"premiere_preview_right_bar premiere_preview_right_footer");
	$footer_div->appendChild( $xml->create_element("span", id=>"premiere_preview_document_info"));
	$panel->appendChild($footer_div);

	#download button, yo
	my $button = $xml->create_element("a", id=>"premiere_preview_download_button", class=>"premiere_preview_button");
	$button->appendChild($xml->create_text_node("Download"));
	$footer_div->appendChild($button);

	return $panel;
};


$c->{eprint_render} = sub
{
	my ( $eprint, $repository, $preview ) = @_;

	my $xml = $repository->xml;

	my $title = $eprint->render_citation("brief");
	#my $title = $xml->create_document_fragment;

	my $page = $xml->create_element("div", id=>"premiere_preview_container");

	# replace this if they every 
	my $naughty_css_hack = $xml->create_element("style", type=>"text/css");
	$naughty_css_hack->appendChild( $xml->create_text_node(".ep_tm_pagetitle { display: none; }"));
	$page->appendChild($naughty_css_hack);

	my $left = $xml->create_element("div", id=>"premiere_preview_left");
	my $right = $xml->create_element("div", id=>"premiere_preview_right");
	# hmmmm, try and find a way to make these divs the correct way around later...
	$page->appendChild($left);
	$page->appendChild($right);

	$left->appendChild( $repository->call("render_premiere_preview_area", $eprint, $repository));
	$right->appendChild( $repository->call("render_premiere_preview_documents", $eprint, $repository));
		
	my $links = $repository->xml->create_document_fragment();
	if( !$preview )
	{
		$links->appendChild( $repository->plugin( "Export::Simple" )->dataobj_to_html_header( $eprint ) );
		$links->appendChild( $repository->plugin( "Export::DC" )->dataobj_to_html_header( $eprint ) );
	}

	# add the main info
	$left->appendChild($eprint->render_citation( "premiere_preview_info" ));

	return( $page, $title, $links );
};
