package EPrints::Plugin::InputForm::Component::Field::Permissions;

use EPrints;
use EPrints::Plugin::InputForm::Component::Field;

@ISA = ( 'EPrints::Plugin::InputForm::Component::Field');

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = 'Permissions Component';
        $self->{visible} = "all";


	return $self;
}

sub parse_config
{
        my( $self, $config_dom ) = @_;

        my @fields = $config_dom->getElementsByTagName( "field" );

        if( scalar @fields != 1 )
        {
                EPrints::abort( "Bad configuration for Field Component\n".$config_dom->toString );
        }
        else
        {
                my $field = $fields[0];
                $self->{config}->{field} = $self->xml_to_metafield( $fields[0] );

		$self->{basename} = $self->{prefix}."_".$self->{config}->{field}->{name};
        }

}

sub render_content
{
#	my ( $field, $repo, $current_value, $dataset, $staff, $hidden_fields, $object, $basename ) = @_;
	my ( $self, $surround ) = @_;
	my $session = $self->{session};
	my $xml = $session->{xml};
	my $basename = $self->{basename};
	my $dataset = $self->{dataobj}->{dataset};
	my $field = $dataset->field("view_permissions");

	# Get the field and its value/default
	my $values;
	if( $self->{dataobj} )
	{
		$values = $self->{dataobj}->get_value( $field->{name} );
	}
	else
	{
		$values = $self->{default};
	}

	my $namedset_name = $dataset->field($field->{name}."_type")->{set_name}; 
	my @permission_types = $session->get_types($namedset_name);
	my %nameset_hash = map { $_ => 1 } @permission_types;

	my $first_value_type = @$values[0]->{type};
	my $show_advanced_options = (not ($first_value_type eq "public" or $first_value_type eq "private" or $first_value_type eq "restricted"));

	# if the first value is a custom type, set the coarse_type to "custom" instead of the actual type
	if ( $show_advanced_options)
	{
		$first_value_type = "custom";
	}

	my $div = $xml->create_element( "div", class=>"edshare_permissions" ); 
	$div->appendChild( $xml->create_element( "input", name=>$basename."_coarse_type", type=>"hidden", value=>$first_value_type ) ); 

	my $ul = $xml->create_element( "ul", id=>$basename."_coarse_options", class=>"edshare_permissions_coarse" );
	$div->appendChild( $ul );
	foreach my $type ('private', 'public', 'restricted')
	{

		if( defined $nameset_hash{$type} )
		{
			my $li = $xml->create_element( "li", id=>$basename."_".$type, onclick=>"permissionsCoarseSelect('$basename', '$type');" );

			if ($first_value_type eq $type)
			{
				$li->setAttribute( class=>"selected" );
			}
			$li->appendChild( $xml->create_element( "img", src=>"/images/edshare_core/permissions/$type.png" ) );
			$li->appendChild( $xml->create_element( "br" ) );
			$li->appendChild( $session->html_phrase( $namedset_name."_typename_".$type ) );

			$ul->appendChild( $li );
			delete $nameset_hash{$type};
		}
	}

	my $xml_string;
	if (%nameset_hash)
	{
		# special case for advanced options

		my $li = $xml->create_element( "li", id=>$basename."_custom", onclick=>"permissionsCoarseSelect('$basename', 'custom');" );

		if ($show_advanced_options)
		{
				$li->setAttribute( class=>"selected" );
		}
		$li->appendChild( $xml->create_element( "img", src=>"/images/edshare_core/permissions/custom.png" ) );
		$li->appendChild( $xml->create_element( "br" ) );
		$li->appendChild( $session->html_phrase( $namedset_name."_typename_custom" ) );

		$ul->appendChild( $li );
	}

	my $advanced = $xml->create_element( "div", id=>$basename."_advanced_options", style=>"padding: 1px;position:relative;"); # mrt - we need 1px padding to stop the margins from collapsing - we need a relative position to anchor the positions - CSS is a very stupid thing
	$div->appendChild( $advanced );

	if (not $show_advanced_options)
	{
		$advanced->setAttribute( style=>"display:none;"); 
	}

	my $left = $xml->create_element( "div", class=>"edshare_permissions_advanced_left" );
	my $right = $xml->create_element( "div", class=>"edshare_permissions_advanced_right" );
	$advanced->appendChild( $right );
	$advanced->appendChild( $left );
	$advanced->appendChild( $xml->create_element( "div", class=>"clearer" ) );

	$left->appendChild( $self->html_phrase( "advanced_left_top" ) );
	$right->appendChild( $self->html_phrase( "advanced_right_top" ) );

	my $table = $xml->create_element( "table", class=>"edshare_permissions_advanced_types" );
	$left->appendChild( $table );

# mrt - maybe I will load the plugins into a nice hashmap a bit later on so I don't spam loading them - but not today....

	# iterate through the array of types and print any that haven't been rendered yet
	foreach my $type (@permission_types)
	{
		if ($nameset_hash{$type})
		{
			my $plugin = $session->plugin( "PermissionType::".$type, parent_component=>$self );
			$table->appendChild( $plugin->render() );
		}
	}


	my $value_list = $xml->create_element( "ul",
		id=>$basename."_advanced_values",
		class=>"edshare_permissions_advanced_values"
	);
	$right->appendChild( $value_list );	

	# render the existing values in the table - gangsta!!
	if ( $show_advanced_options)
	{
		my $add_values_javascript;

		foreach my $permission ( @$values )
		{
			my $plugin = $session->plugin( "PermissionType::".$permission->{type}, parent_component=>$self );
			my $li = $xml->create_element( "li",
				id=>$basename."_".$permission->{type}."_".$permission->{value},
				class=>"edshare_permissions_advanced_value"
			);
			$li->appendChild( $plugin->render_value( $permission->{value} ) );
		
			$value_list->appendChild( $li );			
		}

       		$div->appendChild( $session->make_javascript( "permissionsInitialiseRemoveButtons('".$self->{basename}."');" ) );
	}

	return $div;
}

sub update_from_form
{
        my( $self, $processor ) = @_;
        my $session = $self->{session};
	my $basename = $self->{basename};

        my $obj = $self->{dataobj};

        my $field = $self->{config}->{field};

	my $coarse_type = $session->param( $basename."_coarse_type" );

	if ($coarse_type eq "custom")
	{
		my @types = $session->param($basename."_type");
		my @values = $session->param($basename."_value");

		my @permissions;

		for (my $i=0; $i<@types; $i++)
		{
			push (@permissions, {type=>@types[$i], value=>@values[$i]});	
		}

		$obj->set_value( $field->{name}, \@permissions );
	}
	else
	{	
		$obj->set_value( $field->{name} , [ { type=>$coarse_type, value=>$coarse_type} ]);
	}
}

