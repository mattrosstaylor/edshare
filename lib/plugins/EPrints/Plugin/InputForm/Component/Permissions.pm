package EPrints::Plugin::InputForm::Component::Permissions;

use EPrints;
use EPrints::Plugin::InputForm::Component;

@ISA = ( 'EPrints::Plugin::InputForm::Component');

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = 'Permissions Component';
        $self->{visible} = "all";
	$self->{surround} = "Default";
	return $self;
}


sub parse_config
{
	my( $self, $config_dom ) = @_;

	my @fields = $config_dom->getElementsByTagName( "field" );

	if( scalar @fields != 2 )
	{
		push @{$self->{problems}}, $self->{repository}->html_phrase( "Plugin/InputForm/Component/Field:error_missing_field",
			xml => $self->{repository}->xml->create_text_node( $self->{repository}->xml->to_string( $config_dom ) )
		);
	}
	else
	{
		$self->{config}->{left}->{field} = $self->xml_to_metafield( $fields[0] );
		$self->{config}->{left}->{basename} = $self->{prefix}."_".$self->{config}->{left}->{field}->{name};
		$self->{config}->{right}->{field} = $self->xml_to_metafield( $fields[1] );
		$self->{config}->{right}->{basename} = $self->{prefix}."_".$self->{config}->{right}->{field}->{name};
	}
}
=pod
sub _render_permission_type
{
	my ( $self ) = @_;
	my $session = $self->{session};
	my $xml = $session->{xml};

	my $frag = $xml->create_document_fragment;

	return $frag;
}
=cut

sub render_content
{
	my ( $self, $surround ) = @_;
	my $session = $self->{session};
	my $xml = $session->{xml};

	my $div = $xml->create_element( "div", class=>"edshare_permissions" );
	my $left = $xml->create_element( "div", class=>"edshare_permissions_left" );
	my $right = $xml->create_element( "div", class=>"edshare_permissions_right" );

	$div->appendChild( $left );
	$div->appendChild( $right );

	$left->appendChild( $self->_render_permission_type( $self->{config}->{left} ) );
	$right->appendChild( $self->_render_permission_type( $self->{config}->{right} ) );

	return $div;
}

sub _render_permission_type
{
	my ( $self, $config ) = @_;
	my $session = $self->{session};
	my $xml = $session->{xml};

	my $field = $config->{field};
	my $basename = $config->{basename};
	my $js_var_name = $basename."_object";
	my $dataset = $self->{dataobj}->{dataset};
	my $fieldname = $field->{name};	

	# Get the field and its value/default
	my $values;
	if( $self->{dataobj} )
	{
		$values = $self->{dataobj}->get_value( $fieldname );
	}
	else
	{
		$values = $self->{default};
	}

	my $namedset_name = $dataset->field($fieldname."_type")->{set_name}; 
	my @permission_types = $session->get_types($namedset_name);
	my %nameset_hash = map { $_ => 1 } @permission_types;

	my $first_value_type;
	if ( defined @$values[0] ) 
	{
		$first_value_type = @$values[0]->{type};
	}
	else
	{
		$first_value_type = "private";
	}

	my $show_advanced_options = (not ($first_value_type eq "public" or $first_value_type eq "private" or $first_value_type eq "restricted"));

	# if the first value is a custom type, set the coarse_type to "custom" instead of the actual type
	if ( $show_advanced_options)
	{
		$first_value_type = "custom";
	}

	my $frag = $xml->create_document_fragment; 
	$frag->appendChild( $xml->create_element( "input", name=>$basename."_coarse_type", type=>"hidden", value=>$first_value_type ) ); 

	# initialise the Permissions object
	$frag->appendChild( $session->make_javascript( "var ".$js_var_name." = new inputPermissions( '".$js_var_name."', '".$basename."');" ) );

	my $ul = $xml->create_element( "ul", id=>$basename."_coarse_options", class=>"edshare_permissions_coarse" );
	$frag->appendChild( $ul );
	foreach my $type ('private', 'public', 'restricted')
	{
		if( defined $nameset_hash{$type} )
		{
			my $li = $xml->create_element( "li", id=>$basename."_".$type, onclick=>"$js_var_name.coarseSelect('$type');" );

			if ($first_value_type eq $type)
			{
				$li->setAttribute( class=>"selected" );
			}
			$li->appendChild( $xml->create_element( "img", src=>"/images/edshare/permissions/$type.png" ) );
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

		my $li = $xml->create_element( "li", id=>$basename."_custom", onclick=>"$js_var_name.coarseSelect('custom');" );

		if ($show_advanced_options)
		{
				$li->setAttribute( class=>"selected" );
		}
		$li->appendChild( $xml->create_element( "img", src=>"/images/edshare/permissions/custom.png" ) );
		$li->appendChild( $xml->create_element( "br" ) );
		$li->appendChild( $session->html_phrase( $namedset_name."_typename_custom" ) );

		$ul->appendChild( $li );
	}

	my $advanced_wrapper = $xml->create_element( "div", id=>$basename."_advanced_options_wrapper" );
	my $advanced = $xml->create_element( "div", class=>"edshare_permissions_advanced_options" );

	$advanced_wrapper->appendChild( $advanced );
	$frag->appendChild( $advanced_wrapper );

	if ( not $show_advanced_options )
	{
		$advanced->setAttribute( style=>"display:none;" ); 
	}

	my $table = $xml->create_element( "table", class=>"edshare_permissions_advanced_types" );
	$advanced->appendChild( $table );

# mrt - maybe I will load the plugins into a nice hashmap a bit later on so I don't spam loading them - but not today....

	# iterate through the array of types and print any that haven't been rendered yet
	foreach my $type ( @permission_types )
	{
		if ( $nameset_hash{$type} )
		{
			my $plugin = $session->plugin( "PermissionType::".$type, basename=>$basename, js_var_name=>$js_var_name );
			$table->appendChild( $plugin->render() );
		}
	}

	my $value_list = $xml->create_element( "ul",
		id=>$basename."_advanced_values",
		class=>"edshare_permissions_advanced_values"
	);
	$advanced->appendChild( $value_list );	

	# add the placeholder for when the list is empty
	my $placeholder = $xml->create_element( "li", id=>$basename."_placeholder" );
	$placeholder->appendChild( $session->html_phrase( $fieldname."_advanced_placeholder" ) );
	$value_list->appendChild( $placeholder );

	# render the existing values in the table - gangsta!!
	if ( $show_advanced_options )
	{
		my $add_values_javascript;

		foreach my $permission ( @$values )
		{
			my $plugin = $session->plugin( "PermissionType::".$permission->{type}, parent_component=>$self );
			next if (not defined( $plugin ) );

			$add_values_javascript = $js_var_name.".addPermittedFromString('".$permission->{type}."','".$permission->{value}."','".$plugin->render_value( $permission->{value})."');";
			$frag->appendChild( $session->make_javascript( $add_values_javascript ));
		}
	}

	return $frag;
}

=pod

sub update_from_form
{
        my( $self, $processor ) = @_;
        my $session = $self->{session};
	my $basename = $self->{basename};
        my $field = $self->{config}->{field};

        my $obj = $self->{dataobj};

	my $coarse_type = $session->param( $basename."_coarse_type" );

	if ($coarse_type eq "custom")
	{
		my @types = $session->param($basename."_type");
		my @values = $session->param($basename."_value");

		my @permissions;

		for (my $i=0; $i<@types; $i++)
		{
			push (@permissions, {type=>$types[$i], value=>$values[$i]});	
		}

		$obj->set_value( $field->{name}, \@permissions );
	}
	else
	{	
		$obj->set_value( $field->{name} , [ { type=>$coarse_type, value=>$coarse_type} ]);
	}
}
=cut
