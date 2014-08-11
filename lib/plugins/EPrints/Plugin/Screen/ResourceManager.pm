package EPrints::Plugin::Screen::ResourceManager;

@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

        $self->{appears} = [
                {
                        place => "key_tools",
                        position => 101,
                }
        ];

	return $self;
}

sub can_be_viewed
{
        my( $self ) = @_;

        return $self->allow( "items" ) 
}

sub phrase
{
	my( $self, $id, %bits ) = @_;
	my $base = 'Plugin/Screen/ResourceManager';
	return $self->{session}->phrase( $base.':'.$id, %bits );
}

sub html_phrase
{
	my( $self, $id, %bits ) = @_;
	my $base = 'Plugin/Screen/ResourceManager';
	return $self->{session}->html_phrase( $base.':'.$id, %bits );
}

sub render
{
	my( $self ) = @_;
	my $session = $self->{session};

	my $frag = $session->make_doc_fragment;
	
	my $container = $session->make_element ( "div", id=>"resource_manager_container" );
	my $controls = $session->make_element ( "div" , id=>"resource_manager_left" );
	my $list = $session->make_element( 'div', id=>"resource_manager_right" );
	$container->appendChild( $controls );
	$container->appendChild( $list );
	$frag->appendChild( $container );
	
	my $items = $self->_generate_item_list;
	$controls->appendChild( $self->_render_controls( $items ) );
	$list->appendChild( $self->_render_item_list( $items ) );

	$container->appendChild( $session->make_element( "div", class=>"clearer" ) );
	
	$frag->appendChild( $session->make_javascript( "edshare_suppress_page_title();" ) );
	return $frag;
}

sub _get_current_filter_values
{
	my( $self, $fieldname ) = @_;
	my $session = $self->{session};

        unless( defined $self->{"filter_values_$fieldname"} )
        {
                my $param = $session->param( $fieldname );
                $param =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/ge;
                my @temp = split( ",", $param );
                $self->{"filter_values_$fieldname"} = \@temp;
        }
        my @settings = @{$self->{"filter_values_$fieldname"}};
        return \@settings;
}

sub _get_show_setting
{
	my( $self ) = @_;
	my $show = $self->_get_current_filter_values( "show" );

	if ( not scalar (@$show) ) 
	{
		return $self->{session}->get_repository->get_conf( 'resource_manager_default_show' );
	}
	return @$show[0];
}

sub _render_controls
{
	my( $self, $eprint_list ) = @_;
	my $session = $self->{session};

	my $frag = $session->make_doc_fragment;
	my $title = $session->make_element( "h2" );
	$title->appendChild( $self->render_title );
	$frag->appendChild( $title );

	my @filter_fields = @{$self->{session}->get_repository->get_conf( 'resource_manager_filter_fields' )};

	foreach my $fieldname (@filter_fields)
	{
		$frag->appendChild( $self->_render_filter_control( $fieldname, $eprint_list ) );
	}

	return $frag;
}

sub _render_show_control
{
	my( $self) = @_;
	my $session = $self->{session};

	my $block = $session->make_element( "div", class=>"resource_manager_show_control" );

	my $ul = $session->make_element( "ul" );
	$block->appendChild( $ul );
	my @show_options = qw/mine shared both/;

	my $current_show = $self->_get_show_setting;

	foreach my $show ( @show_options )
	{
		my $li = $session->make_element( "li" );

		if ( $show eq $current_show )
		{
			my $span = $session->make_element( "span", style=>"font-weight:bold" );
			$span->appendChild( $self->html_phrase( "show_$show" ) );
			$li->appendChild( $span );
		}
		else
		{
			my $anchor = $session->make_element( "a", href=>$self->_make_filter_query_string( "show", $show, 0 ) );
			$anchor->appendChild( $self->html_phrase( "show_$show" ) );
			$li->appendChild( $anchor );
		}
		$ul->appendChild( $li );
	}
	return $block;
}

sub _render_filter_control
{
	my ( $self, $fieldname, $eprint_list)= @_;
	my $session = $self->{session};

	my $ds = $session->get_dataset( 'eprint' );
	my $metafield = $ds->get_field( $fieldname );
	my $field_isa_set =  ( $metafield->get_type eq 'set' || $metafield->get_type eq 'namedset' );

	my $block = $session->make_element( "div", class=>"resource_manager_control" );

	my $title = $session->make_element( "div", class=>"resource_manager_control_title" );
	$title->appendChild( $metafield->render_name );
	$block->appendChild( $title );

	my $ul = $session->make_element( "ul" );
	$block->appendChild( $ul );

	# render current filter values

	my $current_filter_values = $self->_get_current_filter_values( $fieldname );
	foreach my $filter ( @$current_filter_values )
	{
		my $li = $session->make_element( "li" );
		my $url = $self->_make_filter_query_string( $fieldname, $filter, -1 );
		my $anchor = $session->make_element( "a", href=>$url, style=>"font-weight: bold" );
		$anchor->appendChild( $session->make_element('img', src => '/images/resource_manager/checkbox_yes.png') );

		if ( $field_isa_set )
		{
			$anchor->appendChild( $metafield->render_single_value( $session, $filter) );
		}
		else
		{
			$anchor->appendChild( $session->make_text( $filter ) );
		}

		$li->appendChild( $anchor );
		$ul->appendChild( $li );
	}

	# current possible filter values
	my $filter_counts = $self->_get_possible_filter_values( $fieldname, $eprint_list );
	foreach my $filter_count ( @$filter_counts )
	{
		my $filter = @$filter_count[0];
		my $count = @$filter_count[1];
		my $li = $session->make_element( "li" );
		my $url = $self->_make_filter_query_string( $fieldname, $filter, 1 );
		my $anchor = $session->make_element( "a", href=>$url );
		$anchor->appendChild( $session->make_element('img', src => '/images/resource_manager/checkbox_no.png') );

		if ( $field_isa_set )
		{
			$anchor->appendChild( $metafield->render_single_value( $session, $filter) );
		}
		else
		{
			$anchor->appendChild( $session->make_text( $filter ) );
		}

		$li->appendChild( $anchor );
		my $count_span = $session->make_element( "span", class=>"resource_manager_filter_count" );
		$count_span->appendChild( $session->make_text( "(".$count.")" ) );
		$li->appendChild( $count_span );
		$ul->appendChild( $li );
	}

	if ( not ( scalar @$current_filter_values or scalar @$filter_counts ) )
	{
		my $li = $session->make_element( "li" );
		$li->appendChild( $self->html_phrase( "no_filter_values" ) );
		$ul->appendChild( $li );
	}
	return $block;
}

sub _make_filter_query_string
{
	my( $self, $fieldname, $value, $mode ) = @_;

	my @filter_fields = @{$self->{session}->get_repository->get_conf( 'resource_manager_filter_fields' )};
	push @filter_fields, "show";

	my $query_string;

	foreach my $filter (@filter_fields)
	{
		my @current_filter_values = @{$self->_get_current_filter_values( $filter )};
		if( $filter eq $fieldname )
		{

			if ( $mode > 0 )
			{
				push @current_filter_values, $value;
			}
			elsif ( $mode < 0 )
			{
				@current_filter_values = grep {!($_ eq $value)} @current_filter_values;
			}
			else
			{
				@current_filter_values = ();
				push @current_filter_values, $value;
			}
		}
		# uri encode each element in the array
		my @escaped_filter_values;
		foreach my $s (@current_filter_values)
		{
			push @escaped_filter_values, EPrints::Utils::uri_escape_utf8( $s );
		}
		$query_string .= '&'.$filter.'='.join( '%2C', @escaped_filter_values ) if scalar @current_filter_values;
	}

	return $self->get_repository->get_conf( 'rel_path' ).'/cgi/users/home?screen=ResourceManager'. $query_string;
}

sub _get_possible_filter_values
{
	my( $self, $fieldname, $eprint_list ) = @_;
	my $session = $self->{session};
	my $database = $session->get_database;

	return () unless( defined $eprint_list && $eprint_list->count );

	my $current_filter_values = $self->_get_current_filter_values( $fieldname );

	my $Q_fieldname = $database->quote_identifier( $fieldname );
	my $Q_eprintid = $database->quote_identifier( 'eprintid' );
	my $Q_eprint_fieldname_table;

	my $ds = $session->get_dataset( 'eprint' );
	my $metafield = $ds->get_field( $fieldname );

	if ( $metafield->get_property( 'multiple' ) )
	{
		$Q_eprint_fieldname_table = $database->quote_identifier( 'eprint_'.$fieldname );
	}
	else
	{
		$Q_eprint_fieldname_table = $database->quote_identifier( 'eprint' );
	}

	my $sql = "SELECT $Q_fieldname, count(*) FROM $Q_eprint_fieldname_table WHERE $Q_fieldname is not null AND";

	$sql .= " $Q_eprintid IN (".join( ",", map { $database->quote_int( $_ ) } @{$eprint_list->get_ids} ).")";

	if( scalar @{$current_filter_values} )
	{
		$sql .= " AND $Q_fieldname NOT IN (".join( ",", map { $database->quote_value( $_ ) } @{$current_filter_values} ).")";
	}

	$sql .= " GROUP BY $Q_fieldname ORDER BY $Q_fieldname";

	my @possible_filter_values;

	my $sth = $database->prepare( $sql );
	$database->execute( $sth, $sql );
	while( my @r = $sth->fetchrow_array )
	{
		push @possible_filter_values, [@r];
	}	

	return \@possible_filter_values;
}

sub _get_filtered_item_list
{
	my( $self ) = @_;
	my $session = $self->{session};
	my $ds = $session->get_dataset( 'eprint' );

	my @field_conditions;
	
	foreach my $field ( @{$session->get_repository->get_conf( 'resource_manager_filter_fields' )} )
	{
		my @values = @{$self->_get_current_filter_values( $field )};
		my @value_conditions;
		foreach my $value (@values)
		{
			push @value_conditions, EPrints::Search::Condition->new( "=", $ds, $ds->get_field( $field ), $value );
		}

		if ( scalar ( @value_conditions ) > 1 )
		{
			push @field_conditions, EPrints::Search::Condition::AndSubQuery->new( "AND", @value_conditions );
		}
		elsif ( scalar ( @value_conditions ) == 1 )
		{
			push @field_conditions, @value_conditions[0];
		}
	}

	my $condition;
	if ( scalar ( @field_conditions ) > 1 )
	{
		$condition = EPrints::Search::Condition->new( "AND", @field_conditions );
	}
	elsif ( scalar ( @field_conditions ) == 1 )
	{
		$condition = @field_conditions[0];
	}

	return if not $condition;
	return EPrints::List->new(
		session => $session, 
		dataset => $ds, 
		ids => $condition->process(
				session => $session,
				dataset => $ds 
		) 
	);
}

sub _render_item_list
{
	my( $self, $eprint_list ) = @_;
	my $session = $self->{session};

	my $item_list = $session->make_doc_fragment;

	my $controls = $session->make_element( "div", class=>"resource_manager_top_controls" );
	$item_list->appendChild( $controls );
	$controls->appendChild( $self->_render_show_control );
	$controls->appendChild( $self->render_action_list_bar( "item_tools" ) );
	$controls->appendChild( $session->make_element( "div", class=>"clearer" ) );

	if( !$eprint_list->count )
	{
		$item_list->appendChild( $session->html_phrase( 'Plugin/Screen/ResourceManager:no_resources' ) );
	}
	else
	{
		my %info;
		$info{dom} = $item_list;
		
		$eprint_list->map( sub{
			my( $session, $dataset, $eprint, $info ) = @_;

			my $owned = ($session->current_user->id == $eprint->value("userid"));
			my $url;
			if( $eprint->value( 'eprint_status' ) eq 'archive' )
			{
				$url = $eprint->get_url;
			}
			else
			{
				$url = $session->get_repository->get_conf( 'rel_path' ).'/cgi/users/home?screen=EPrint::Summary&eprintid='.$eprint->get_id;
			}
			my $container;
			if ( $owned )
			{
				$container = $session->make_element( "div", id => "manageable_id_".$eprint->get_id, class => "manageable" );
			}
			else
			{

				$container = $session->make_element( "div", id => "manageable_id_".$eprint->get_id, class => "manageable manageable_shared" );
			}			

			my $flags = {
					can_remove=> $owned,
					can_edit=> $eprint->could_obtain_lock( $session->current_user ),
			};
			$container->appendChild( $eprint->render_citation( 'manageable', url => $url, flags=>$flags ) );
			$info->{dom}->appendChild( $container );
		}, \%info );
	}
	
	return $item_list;
}

sub _generate_item_list
{
	my( $self ) = @_;
	my $session = $self->{session};

	my $user = $session->current_user;
        my $ds = $session->get_dataset( 'eprint' );

	my $show = $self->_get_show_setting;

	my $my_items;

	if ( $show eq "mine" or $show eq "both" )
	{
		my $search = EPrints::Search->new(
			dataset => $ds,
			session => $session,
			order => "-lastmod",
		);

		$search->add_field( $ds->get_field("userid"), $user->id);

		$my_items = $search->perform_search;
	}
	else
	{
		$my_items = EPrints::List->new(
			dataset => $ds,
			session => $session,
			ids => [],
		);
	}

	my $shared_items = EPrints::List->new(
		dataset => $ds,
		session => $session,
		ids => [],
	);

	if ( $show eq "shared" or $show eq "both" )
	{
	
		my @permission_types = qw/ Creators UserLookup/; 
		foreach my $type (@permission_types)
		{
			my $plugin = $session->plugin( "PermissionType::".$type, fieldname=>"edit_permissions" );
			next if (not defined $plugin);
			
			$shared_items = $shared_items->union( $plugin->get_permitted_items_for_user( $user ) );	
		}

		$shared_items = $shared_items->remainder( $my_items );
	}
	my $all_items = $my_items->union( $shared_items );

	my $filtered_items = $self->_get_filtered_item_list;
	if ( defined $filtered_items )
	{
		$all_items = $all_items->intersect( $filtered_items );
	}

	return $all_items->reorder( "-lastmod" );
}

1;
