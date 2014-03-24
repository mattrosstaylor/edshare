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

sub render_title
{
	my( $self, $surround ) = @_;
	my $session = $self->{session};

	return $session->html_phrase( "sys:ep_form_required", label=>$self->html_phrase( "title" ) );
}

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

	$left->appendChild( $self->_render_content_helper( $self->{config}->{left} ) );
	$right->appendChild( $self->_render_content_helper( $self->{config}->{right} ) );

	return $div;
}

sub _render_list
{
        my ( $self, $config ) = @_;
	my $session = $self->{session};
	my $xml = $session->{xml};

	my $basename = $config->{basename};
	my $fieldname = $config->{field}->{name};	

	# add the value list
	my $list = $xml->create_element( "ul",
		id=>$basename."_advanced_list",
		class=>"edshare_permissions_advanced_list"
	);

	# add the placeholder for when the list is empty
	my $placeholder = $xml->create_element( "li", id=>$basename."_placeholder", class=>"edshare_permissions_advanced_placeholder edshare_permissions_advanced_value" );
	$placeholder->appendChild( $session->html_phrase( $fieldname."_advanced_placeholder" ) );
	$list->appendChild( $placeholder );

	return $list;
}

sub _render_coarse_option
{
	my ( $self, $type, $basename, $fieldname, $namedset_name, $first_value_type, $js_var_name ) = @_;
	my $session = $self->{session};
	my $xml = $session->{xml};

	my $li = $xml->create_element( "li", id=>$basename."_".$type, onclick=>"$js_var_name.coarseSelect('$type');" );

	if ( $first_value_type eq $type )
	{
		$li->setAttribute( class=>"selected" );
	}
	$li->appendChild( $xml->create_element( "img", src=>"/images/edshare/$fieldname/$type.png" ) );
	$li->appendChild( $xml->create_element( "br" ) );
	$li->appendChild( $session->html_phrase( $namedset_name."_typename_".$type ) );

	return $li;
}


sub _render_content_helper
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
	my $legend = $xml->create_element( "div", class=>"edshare_permissions_legend" );
	$legend->appendChild( $field->render_help );
	$frag->appendChild( $legend );	

	my $content = $xml->create_element( "div", class=>"edshare_permissions_content" );
	$frag->appendChild( $content );

	# initialise the Permissions object
	$content->appendChild( $session->make_javascript( "var ".$js_var_name." = new inputPermissions( '".$js_var_name."', '".$basename."');" ) );
	$content->appendChild( $xml->create_element( "input", name=>$basename."_coarse_type", type=>"hidden", value=>$first_value_type ) ); 
	
	my $ul = $xml->create_element( "ul", id=>$basename."_coarse_options", class=>"edshare_permissions_coarse" );
	$content->appendChild( $ul );
	
	foreach my $type ('private', 'public', 'restricted')
	{
		if( defined $nameset_hash{$type} )
		{	
			$ul->appendChild( $self->_render_coarse_option( $type, $basename, $fieldname, $namedset_name, $first_value_type, $js_var_name ) );
			delete $nameset_hash{$type};
		}
	}

	my $xml_string;
	if (%nameset_hash)
	{
		# special case for advanced options
		$ul->appendChild( $self->_render_coarse_option( "custom", $basename, $fieldname, $namedset_name, $first_value_type, $js_var_name ) );
	}

	my $advanced_wrapper = $xml->create_element( "div", id=>$basename."_advanced_options_wrapper" );
	my $advanced = $xml->create_element( "div", class=>"edshare_permissions_advanced_options" );

	$advanced_wrapper->appendChild( $advanced );
	$content->appendChild( $advanced_wrapper );

	if ( not $show_advanced_options )
	{
		$advanced_wrapper->setAttribute( style=>"display:none;" ); 
	}

	# sort the permissions by type, son
	my $values_by_type = {};
	foreach my $permission ( @$values )
	{
		my $type = $permission->{type};
		my $value = $permission->{value};
		if ( not exists $values_by_type->{$type} )
		{
			$values_by_type->{$type} = [];
		}
		push ( $values_by_type->{$type}, $value );
	}

# mrt - maybe I will load the plugins into a nice hashmap a bit later on so I don't spam loading them - but not today....
	# iterate through the array of types and print any that haven't been rendered yet
	my $list_element_added = 0;
	foreach my $type ( @permission_types )
	{
		if ( $nameset_hash{$type} )
		{
			my $plugin = $session->plugin( "PermissionType::".$type, basename=>$basename, fieldname=>$fieldname, js_var_name=>$js_var_name );
			if (not $list_element_added and $plugin->requires_list )
			{
				$advanced->appendChild( $self->_render_list( $config ) );
				$list_element_added = 1;
			}
			my $type_div = $xml->create_element( "div", class=>"edshare_permissions_advanced_type" );
			$type_div->appendChild( $plugin->render( $values_by_type->{$type} ) );
			$advanced->appendChild( $type_div );
		}
	}
	return $frag;
}

sub update_from_form
{
	my( $self, $processor ) = @_;
	$self->_update_from_form_helper( $processor, $self->{config}->{left} );
	$self->_update_from_form_helper( $processor, $self->{config}->{right} );
}


sub _update_from_form_helper
{
        my( $self, $processor, $config ) = @_;
        my $session = $self->{session};
	my $basename = $config->{basename};
        my $field = $config->{field};

        my $obj = $self->{dataobj};

	my $coarse_type = $session->param( $basename."_coarse_type" );

	if ($coarse_type eq "custom")
	{
		my @permissions;

		foreach my $param ( $session->param ) {
			if ( $param =~ /$basename/ )
			{
				my $type = substr( $param, length( $basename."_" ) );
				next if ( $type eq "coarse_type" );

				foreach my $value ($session->param( $param ) )
				{	
					push (@permissions, {type=>$type, value=>$value } );
				}
			}
		}

		if ( scalar ( @permissions) == 0 )
		{
			$processor->add_message( "warning", $self->html_phrase( "no_custom_values", field=>$field->render_name, revert=>$session->html_phrase( $field->name."_typename_private" ) ) );
			push (@permissions, {type=>"private", value=>"private" } );
		} 

		$obj->set_value( $field->{name}, \@permissions );
	}
	else
	{	
		$obj->set_value( $field->{name} , [ { type=>$coarse_type, value=>$coarse_type} ]);
	}
}
