$c->{can_request_view_document} = sub
{
	my( $doc, $r ) = @_;

	my $eprint = $doc->get_eprint();
	my $status = $eprint->value( "eprint_status" );
	my $user = $eprint->repository->current_user();
	
	if( $status ne "archive" )
	{
		return( "DENY" );
	}

	if( defined $user && ($user->value( "usertype" ) eq 'admin' || $user->value( "usertype" ) eq 'editor' ))
	{
		return "ALLOW";
	}

	foreach my $permission (@{$eprint->value("view_permissions")})
	{
		if($permission->{type} eq 'public'){ return "ALLOW"; }
		if($permission->{type} eq 'restricted' && defined $user){ return "ALLOW"; }  
		if($permission->{type} eq 'user' && defined $user && $user->value("username") eq $permission->{value} ){ return "ALLOW"; } 
		if($permission->{type} eq 'department' && defined $user && $user->value("department") eq $permission->{value} ){ return "ALLOW"; } 
	}

	return "DENY";
};

$c->{can_user_view_document} = sub
{
	my( $doc, $user ) = @_;

	my $eprint = $doc->get_eprint();
	my $status = $eprint->value( "eprint_status" );

	if( $status ne "archive" )
	{
		return( "DENY" );
	}

	if( defined $user && ($user->value( "usertype" ) eq 'admin' || $user->value( "usertype" ) eq 'editor' ))
	{
		return "ALLOW";
	}

	foreach my $permission (@{$eprint->value("view_permissions")})
	{
		if($permission->{type} eq 'public'){ return "ALLOW"; }
		if($permission->{type} eq 'restricted' && defined $user){ return "ALLOW"; }  
		if($permission->{type} eq 'user' && defined $user && $user->value("username") eq $permission->{value} ){ return "ALLOW"; } 
		if($permission->{type} eq 'department' && defined $user && $user->value("department") eq $permission->{value} ){ return "ALLOW"; } 
	}

	return "DENY";

};

$c->{does_user_own_eprint} = sub
{
	my( $session, $user, $eprint ) = @_;

	return 1 if $user->get_value( "userid" ) == $eprint->get_value( "userid" );

	# add code for checking permissions here

	return 0;
};


