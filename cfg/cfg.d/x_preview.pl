$c->{preview_dimensions} = sub 
{
	my $dimensions;
	$dimensions->{width} = 640;
	$dimensions->{height} = 480;
	return $dimensions;
};

# enable audio_*/video_* previews
$c->{thumbnail_types} = sub 
{
	my( $list, $repo, $doc ) = @_;
	push @$list, qw( pdf );
};

$c->{init_preview_script} = sub
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

	my $script = <<EOF;
document.observe('dom:loaded', function(){
	initPreview($eprintid, $docid);
});
EOF
	my $js = $xml->create_element( "script", type=>"text/javascript" );
	$js->appendChild( $xml->create_text_node($script) );

	return $js;
};
