$c->{"premiere_preview_width"} = 640;
$c->{"premiere_preview_height"} = 480;

$c->{plugins}{"Convert::OfficeToPDF"}{params}{disable} = 0;

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
	my $d = 0;

	my $preview_area = $xml->create_element("iframe", "id"=>"premiere_preview_area", "src"=>"/cgi/preview?d=".$d, "style"=>"width:".$w."px;height:".$h."px;", "scrolling"=>"no");
	$div->appendChild($preview_area);
	return $div;
}
