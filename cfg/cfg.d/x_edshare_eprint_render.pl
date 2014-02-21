$c->{summary_page_metadata} = [qw/
	userid
	lastmod
	creators
	keywords
	license
/];

# IMPORTANT NOTE ABOUT SUMMARY PAGES
#
# While you can completely customise them using the perl subroutine
# below, it's easier to edit them via citation/eprint/summary_page.xml


######################################################################

=item $xhtmlfragment = eprint_render( $eprint, $repository, $preview )

This subroutine takes an eprint object and renders the XHTML view
of this eprint for public viewing.

Takes two arguments: the L<$eprint|EPrints::DataObj::EPrint> to render and the current L<$repository|EPrints::Session>.

Returns three XHTML DOM fragments (see L<EPrints::XML>): C<$page>, C<$title>, (and optionally) C<$links>.

If $preview is true then this is only being shown as a preview.
(This is used to stop the "edit eprint" link appearing when it makes
no sense.)

=cut

######################################################################

$c->{render_fragments} = sub
{
	my ( $eprint, $repository, $preview, $fragments ) = @_;
	
	my $xml = $repository->xml;	

	$fragments->{preview} = $repository->call("render_preview", $eprint, $repository);

	return $fragments;
};

$c->{eprint_render} = sub
{
	my ( $eprint, $repository, $preview ) = @_;

	my $succeeds_field = $repository->dataset( "eprint" )->field( "succeeds" );
	my $commentary_field = $repository->dataset( "eprint" )->field( "commentary" );

	my $flags = { 
		has_multiple_versions => $eprint->in_thread( $succeeds_field ),
		in_commentary_thread => $eprint->in_thread( $commentary_field ),
		preview => $preview,
	};
	my %fragments = ();
	$repository->call("render_fragments", $eprint, $repository, $preview, \%fragments);

	foreach my $key ( keys %fragments ) { $fragments{$key} = [ $fragments{$key}, "XHTML" ]; }
	
	my $page = $eprint->render_citation( "edshare_summary_page", %fragments, flags=>$flags );

	my $title = $eprint->render_citation("brief");

	my $links = $repository->xml()->create_document_fragment();
	if( !$preview )
	{
		$links->appendChild( $repository->plugin( "Export::Simple" )->dataobj_to_html_header( $eprint ) );
		$links->appendChild( $repository->plugin( "Export::DC" )->dataobj_to_html_header( $eprint ) );
	}

	return( $page, $title, $links );
};


