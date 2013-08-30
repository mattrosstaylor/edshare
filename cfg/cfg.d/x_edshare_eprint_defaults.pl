$c->{set_eprint_defaults} = sub
{
	my( $data, $session ) = @_;
	if(!EPrints::Utils::is_set( $data->{type} ))
	{
		$data->{type} = "resource";
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
