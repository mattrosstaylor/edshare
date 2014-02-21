# extra actions for eprint_automatic_fields
$c->{edshare_set_eprint_automatic_fields} = $c->{set_eprint_automatic_fields}; 
$c->{set_eprint_automatic_fields} = sub
{
	my ($eprint) = @_;
	my $repo = $eprint->{session};

	$repo->call('edshare_set_eprint_automatic_fields', $eprint);

	# normalise the keywords (if any) for the browse views
	my $k = $eprint->get_value( "raw_keywords" ); 
	unless( EPrints::Utils::is_set( $k ) )
	{ 
		$eprint->set_value( "keywords", undef ); 
	} 
	else
	{
		my @nk;
		foreach(@$k)
		{
			push @nk, EPrints::Plugin::EdShareUtils::normalise_keyword( $_ );
		}
		$eprint->set_value( "keywords", \@nk );
	}
};
