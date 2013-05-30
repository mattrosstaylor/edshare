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

	my $preview_area = $xml->create_element( "iframe", id=>"premiere_preview_area", "scrolling"=>"no" );
	my $js = $xml->create_element( "script", type=>"text/javascript" );
	$js->appendChild( $xml->create_text_node($script) );
	$div->appendChild( $preview_area );
	$div->appendChild( $eprint->render_citation("premiere_preview_document_list") );
	$div->appendChild( $js );
	return $div;
};

# replace top_left fragment with premiere_preview area
$c->{premiere_preview_render_fragments} = $c->{render_fragments};
$c->{render_fragments} = sub
{
	my ( $eprint, $repository, $preview, $fragments ) = @_;
	$repository->call("premiere_preview_render_fragments", $eprint, $repository, $preview, $fragments);
	$fragments->{top_left} = $repository->call("render_premiere_preview_area", $eprint, $repository);
	return $fragments;
};
