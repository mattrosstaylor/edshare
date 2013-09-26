$c->{set_eprint_defaults} = sub
{
	my( $data, $session ) = @_;
	if(!EPrints::Utils::is_set( $data->{type} ))
	{
		$data->{type} = "resource";
	}

	# add the depositor as first creator:
	my $user = $session->current_user;
	if(defined $user)
	{
		my %creator;
		$creator{name} = $user->get_value("name");
		$creator{id} = $user->get_value("email");
		my @creators;
		$creators[0] = \%creator;
		$data->{creators} = \@creators;
	}


	if(!defined $data->{view_permissions})
	{
		$data->{view_permissions} = [ { type=>"private", value=>"private" } ];
	}

	if(!defined $data->{validation_status})
	{
		$data->{validation_status} = "error";
	}
};
