$c->{collate_permission_values_by_type} = sub
{
	my( $permissions ) = @_;

	my $values_by_type = {};
	foreach my $permission ( @$permissions )
	{
		my $type = $permission->{type};
		my $value = $permission->{value};
		if ( not exists $values_by_type->{$type} )
		{
			$values_by_type->{$type} = [];
		}
		push ( $values_by_type->{$type}, $value );
	}
	return $values_by_type;
};

$c->{is_user_permitted} = sub
{
	my( $user, $eprint, $fieldname) = @_;

	my $repository = $eprint->repository;

	my $values_by_type = $eprint->repository->call( "collate_permission_values_by_type", $eprint->value( $fieldname ) );

	# check basic permissions
	if ( exists $values_by_type->{private} ) { return "DENY"; }
	if ( exists $values_by_type->{public} ) { return "ALLOW"; }

	# if permissions are not public - anyone not logged in will be rejected here.
	if ( not defined $user ) { return "DENY"; }
	if ( exists $values_by_type->{restricted} ) { return "ALLOW"; }

	foreach my $type ( keys $values_by_type )
	{
		my $plugin = $repository->plugin( "PermissionType::".$type );
		next if (not defined $plugin);
		if ( $plugin->test( $user, $eprint, $values_by_type->{$type} ) eq "ALLOW" ) { return "ALLOW"; }
	}
	return "DENY";
};


$c->{can_request_view_document} = sub
{
	my( $doc, $r ) = @_;
	
	my $repo = $doc->get_eprint->repository;
	my $user = $repo->current_user;
	return $repo->call( "can_user_view_document", $doc, $user );
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

	return $eprint->repository->call( "is_user_permitted", $user, $eprint, "view_permissions" );
};

$c->{does_user_own_eprint} = sub
{
	my( $session, $user, $eprint ) = @_;

	return 1 if $user->get_value( "userid" ) == $eprint->get_value( "userid" );

	return 1 if ($session->call( "is_user_permitted", $user, $eprint, "edit_permissions") eq "ALLOW");

	return 0;
};

