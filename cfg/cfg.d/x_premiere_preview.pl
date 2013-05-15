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
	my $w = $repository->get_conf("premiere_preview_width");
	my $h = $repository->get_conf("premiere_preview_height");

	my $first_document = ($eprint->get_all_documents())[0];
	my $docid = $first_document->id;

	my $script = <<EOF;
document.observe('dom:loaded', function(){
	setPremierePreview($docid);
});
EOF


	my $preview_area = $xml->create_element("iframe", id=>"premiere_preview_area", style=>"width:".$w."px;height:".$h."px;", "scrolling"=>"no");
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
	my $document_count_div = $xml->create_element("div", class=>"premiere_preview_right_header", style=>"height:15px;padding:5px;");
	$panel->appendChild($document_count_div);
	my $document_count = scalar($eprint->get_all_documents());
	
	if ($document_count eq 1)
	{
		$document_count_div->appendChild($repository->html_phrase("premiere_preview_document_count_one"));
	}
	else
	{
		$document_count_div->appendChild(
			$xml->create_text_node(
				$repository->phrase("premiere_preview_document_count", count=>$document_count)
			)
		);
	}
	
	# document list
	my $document_list_div = $xml->create_element("div", style=>"overflow-y:scroll;overflow:auto;height:430px;");
	my $document_list = $xml->create_element("ol", class=>"premiere_preview_document_list");
	$document_list_div->appendChild($document_list);
	$panel->appendChild($document_list_div);
	
	foreach ($eprint->get_all_documents())
	{
		$document_list->appendChild($_->render_citation("premiere_preview_selector"));
	}
	foreach ($eprint->get_all_documents())
	{
		$document_list->appendChild($_->render_citation("premiere_preview_selector"));
	}
	foreach ($eprint->get_all_documents())
	{
		$document_list->appendChild($_->render_citation("premiere_preview_selector"));
	}
	foreach ($eprint->get_all_documents())
	{
		$document_list->appendChild($_->render_citation("premiere_preview_selector"));
	}
	foreach ($eprint->get_all_documents())
	{
		$document_list->appendChild($_->render_citation("premiere_preview_selector"));
	}

	# footer
	my $footer = $xml->create_element("div", class=>"premiere_preview_right_header", style=>"position: relative; bottom:0; height:15px; padding: 5px;");
	$footer->appendChild( $xml->create_text_node("DOWNLOAD BUTTON GOES HERE"));
	$panel->appendChild($footer);

	return $panel;
};


$c->{eprint_render} = sub
{
	my ( $eprint, $repository, $preview ) = @_;

	my $xml = $repository->xml;
	my $w = $repository->get_conf("premiere_preview_width");
	my $h = $repository->get_conf("premiere_preview_height");


	my $title = $eprint->render_citation("brief");
	#my $title = $xml->create_document_fragment;

	my $page = $xml->create_element("div", id=>"premiere_preview_container");

	# replace this if they every 
	my $naughty_css_hack = $xml->create_element("style", type=>"text/css");
	$naughty_css_hack->appendChild( $xml->create_text_node(".ep_tm_pagetitle { display: none; }"));
	$page->appendChild($naughty_css_hack);

	my $left = $xml->create_element("div", id=>"premiere_preview_left", style=>"float:left;width:".$w."px");
	my $right = $xml->create_element("div", id=>"premiere_preview_right", style=>"margin-left:".$w."px; height:".$h."px;position:relative;");
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
	#$left->appendChild($eprint->render_citation( "premiere_preview_info" ));

	return( $page, $title, $links );
};


