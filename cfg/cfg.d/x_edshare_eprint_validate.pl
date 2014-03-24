

######################################################################
#
# validate_eprint( $eprint, $repository, $for_archive ) 
#
######################################################################
#
# $eprint 
# - EPrint object
# $repository 
# - Repository object (the current repository)
# $for_archive
# - boolean (see comments at the start of the validation section)
#
# returns: @problems
# - ARRAY of DOM objects (may be null)
#
######################################################################
# Validate the whole eprint, this is the last part of a full 
# validation so you don't need to duplicate tests in 
# validate_eprint_meta, validate_field or validate_document.
#
######################################################################

$c->{validate_eprint} = sub
{
	my( $eprint, $repository, $for_archive ) = @_;

	my $xml = $repository->xml();

	my @problems = ();

	# if there are no documents, then we have a problem
	if ( not scalar $eprint->get_all_documents() )
	{
		push @problems, $repository->html_phrase( "validate:no_documents");
	}

	return( @problems );
};
