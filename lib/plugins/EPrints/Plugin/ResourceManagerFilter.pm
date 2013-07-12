package EPrints::Plugin::ResourceManagerFilter;

@ISA = ( 'EPrints::Plugin' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	return $self;
}

######################################################################
=pod

=item \@filter_fields = $filter->get_filter_fields( [$fields] )

Returns the list of filter fields that should be used with this
filter. If you don't supply the filters parameter then this function
will return the fields defined by resourcemanager_filter_fields. If
you supply fields then that list is tested to ensure that all of the
fields are valid for use with the filter. The returned list will be
the list of fields that are valid for use. 

=cut
######################################################################
sub get_filter_fields
{
	my( $self, $fields ) = @_;

	my @filter_fields = ( defined $fields ? @{$fields} : @{$self->{session}->get_repository->get_conf( 'resourcemanager_filter_fields' )} );
	
	return \@filter_fields;
}

sub render_filter_control
{
	my( $self, $eprint_list, $fields ) = @_;

	my $session = $self->{session};
	my $frag = $session->make_element( 'div', class=>"ed_resourcemanager_filter_box_content" );
	my $user = $session->current_user;

	unless( defined $user )
	{
		$session->get_repository->log( "The filter control requires that a user be logged in, no logged in user was found. Aborting filter rendering." );
		return $frag;
	}

	if( defined $fields )
	{
		$fields = $self->get_filter_fields( @{$fields} );
	}
	else 
	{
		$fields = $self->get_filter_fields;
	}


	my $at_least_one_filter_available = 0;
	my( %possible_filter_values, %current_filter_values );
	my( @possible_filter_links, @current_filter_links );
	map {
		my $field = $_;
		my @links;

		my $ds = $session->get_dataset( 'eprint' );
		my $metafield = $ds->get_field( $field );

		$current_filter_values{$field} = $self->get_current_filter_values( $field );
		$possible_filter_values{$field} = $self->_get_possible_filter_values( $field, $eprint_list, $current_filter_values{$field} );
	
		map {
			my $filter = $_;
			my @filter_values = grep { not $filter eq $_ } @{$current_filter_values{$field}};
			my $filter_link_url = $session->get_repository->get_conf( 'rel_path' ).'/cgi/users/home?screen=ResourceManager&'.EPrints::Utils::url_escape( $self->create_remove_filter_query_string( $field, $filter ) );
			my $filter_link = $session->make_element( 'a', href => $filter_link_url, class => 'ep_resourcemanager_tag ep_resourcemanager_tag_active' );
			$filter_link->appendChild( $session->make_element('img', src => '/images/resource_manager/checkbox_yes.png') );
			if ( $metafield->get_type eq 'set' || $metafield->get_type eq 'namedset' )
			{
				$filter_link->appendChild( $metafield->render_single_value( $session, $filter) );
			}
			else
			{
				$filter_link->appendChild( $session->make_text( $filter ) );
			}
			push @links, $filter_link;
		} @{$current_filter_values{$field}};
		
		map {
			my $filter = $_;
			my $filter_link_url = $session->get_repository->get_conf( 'rel_path' ).'/cgi/users/home?screen=ResourceManager&'.EPrints::Utils::url_escape( $self->create_add_filter_query_string( $field, $filter ) );
			my $filter_link = $session->make_element( 'a', href => $filter_link_url, class => 'ep_resourcemanager_tag' );
			$filter_link->appendChild( $session->make_element('img', src => '/images/resource_manager/checkbox_no.png') );
			if ( $metafield->get_type eq 'set' || $metafield->get_type eq 'namedset' )
			{
				$filter_link->appendChild( $metafield->render_single_value( $session, $filter) );
			}
			else
			{
				$filter_link->appendChild( $session->make_text( $filter ) );
			}
			push @links, $filter_link;
		} @{$possible_filter_values{$field}};

		if( scalar @links )
		{
			$at_least_one_filter_available = 1;
			my $field_title = $session->make_element("div", class=>"ed_resourcemanager_filter_box_field_title");
			$field_title->appendChild( $metafield->render_name );
			$frag->appendChild( $field_title );
			map { $frag->appendChild( $_ );$frag->appendChild( $session->make_element( "br" ) ); } @links;
		}

	} @{$fields};

	if (not $at_least_one_filter_available)
	{
		$frag->appendChild( $session->html_phrase( "Plugin/ResourceManagerFilter:no_available_filters" ) );
	}

	return $frag;
}

sub create_add_filter_query_string
{
	my( $self, $field, $value ) = @_;

	my $query_string;

	map {
		$query_string .= '&' if length $query_string > 0;
		my @current_filter_values = @{$self->get_current_filter_values( $_ )};
		if( $_ eq $field )
		{
			push @current_filter_values, $value;
		}
		$query_string .= $_.'='.join( ',', @current_filter_values ) if scalar @current_filter_values;
	} @{$self->{session}->get_repository->get_conf( 'resourcemanager_filter_fields' )};

	return $query_string;
}

sub create_remove_filter_query_string
{
	my( $self, $field, $value ) = @_;

	my $query_string;

	map {
		$query_string .= '&' if length $query_string > 0;
		my @current_filter_values = @{$self->get_current_filter_values( $_ )};
		if( $_ eq $field )
		{
			@current_filter_values = grep {!($_ eq $value)} @current_filter_values;
		}
		$query_string .= $_.'='.join( ',', @current_filter_values ) if scalar @current_filter_values;
	} @{$self->{session}->get_repository->get_conf( 'resourcemanager_filter_fields' )};

	return $query_string;
}

sub get_current_filter_values
{
	my( $self, $field ) = @_;

	unless( defined $self->{"current_filter_values_$field"} )
	{
		my $session = $self->{session};
		my $tag_line = $session->param( $field );
		$tag_line =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/ge;
		my @temp = split( ",", $tag_line );
		$self->{"current_filter_values_$field"} = \@temp;
	}
	my @current_filter_values = @{$self->{"current_filter_values_$field"}};
	return \@current_filter_values;
}

sub _get_possible_filter_values
{
	my( $self, $field, $eprint_list, $current_filter_values ) = @_;

	return () unless( defined $eprint_list && $eprint_list->count );

	my $session = $self->{session};
	my @possible_filter_values;

	my $Q_fieldname = $session->get_database->quote_identifier( $field );
	my $Q_eprintid = $session->get_database->quote_identifier( 'eprintid' );
	my $Q_eprint_fieldname_table;

	my $ds = $session->get_dataset( 'eprint' );
	my $metafield = $ds->get_field( $field );

	if ( $metafield->get_property( 'multiple' ) )
	{
		$Q_eprint_fieldname_table = $session->get_database->quote_identifier( 'eprint_'.$field );
	}
	else
	{
		$Q_eprint_fieldname_table = $session->get_database->quote_identifier( 'eprint' );
	}

	my $sql = "SELECT $Q_fieldname FROM $Q_eprint_fieldname_table WHERE ";
	
	$sql .= " $Q_eprintid IN (".join( ",", map { $session->get_database->quote_int( $_ ) } @{$eprint_list->get_ids} ).")";

	if( scalar @{$current_filter_values} )
	{
		$sql .= " AND $Q_fieldname NOT IN (".join( ",", map { $session->get_database->quote_value( $_ ) } @{$current_filter_values} ).")";
	}
	
	$sql .= " GROUP BY $Q_fieldname ORDER BY $Q_fieldname";

	my $sth = $session->get_database->prepare( $sql );
	$session->get_database->execute( $sth, $sql );
	while( my $r = $sth->fetchrow_array )
	{
		push @possible_filter_values, $r;
	}

	return \@possible_filter_values;
}

1;
