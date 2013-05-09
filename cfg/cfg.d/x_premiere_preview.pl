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
#	my $doc = $eprint->documents->[0];
#	my $docid = $doc->id;

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
}
