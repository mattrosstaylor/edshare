$c->{preview_width} = 700;
$c->{preview_height} = 525;


# enable audio_*/video_* previews
$c->{thumbnail_types} = sub {
	my( $list, $repo, $doc ) = @_;
	push @$list, qw( pdf );
};

$c->{render_preview} = sub
{
	my ( $eprint, $repository ) = @_;
	my $xml = $repository->xml;

	my $first_document = ($eprint->get_all_documents())[0];
	my $docid;

	if (defined $first_document)
	{
		$docid = $first_document->id;
	}
	else
	{
		$docid = -1;
	}

	my $eprintid = $eprint->id;

	my $div = $xml->create_element( "div", id=>"preview_main");
	$div->appendChild($xml->create_element( "img", src=>"/images/preview/ajax-loader.gif", class=>"preview_ajax" ) );	

	my $script = <<EOF;
document.observe('dom:loaded', function(){
	initPreview($eprintid, $docid);
});
EOF
	my $js = $xml->create_element( "script", type=>"text/javascript" );
	$js->appendChild( $xml->create_text_node($script) );
	$div->appendChild( $js );

	return $div;
};
