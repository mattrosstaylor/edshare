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


sub render_content
{
#	my ( $field, $repo, $current_value, $dataset, $staff, $hidden_fields, $object, $basename ) = @_;
	my ( $self, $surround ) = @_;
	my $session = $self->{session};
	my $xml = $session->{xml};
	my $basename = $self->{prefix}."_view_permissions";
	my $dataset = $self->{dataobj}->{dataset};
	my $field = $dataset->field("view_permissions");

	# Get the field and its value/default
	my $value;
	if( $self->{dataobj} )
	{
		$value = $self->{dataobj}->get_value( $field->{name} );
	}
	else
	{
		$value = $self->{default};
	}

	my $namedset_name = $dataset->field($field->{name}."_type")->{set_name}; 
	my @view_permission_types = $session->get_types($namedset_name);
	my %nameset_hash = map { $_ => 1 } @view_permission_types;

	my $first_value_type = @$value[0]->{type};
	my $show_advanced_options = (not ($first_value_type eq "public" or $first_value_type eq "private" or $first_value_type eq "restricted"));

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
			$li->appendChild( $xml->create_element( "img", src=>"/images/edshare_core/$type.png" ) );
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
		$li->appendChild( $xml->create_element( "img", src=>"/images/edshare_core/custom.png" ) );
		$li->appendChild( $xml->create_element( "br" ) );
		$li->appendChild( $session->html_phrase( $namedset_name."_typename_custom" ) );

		$ul->appendChild( $li );
	}

	# advanced options sections
	$xml_string .= '<div id="'.$basename.'_advanced_options" ';
	if (not $show_advanced_options)
	{
		$xml_string .= 'style="display:none"';
	} 
	$xml_string .= '>';
	$xml_string .= '<div>'.$session->phrase("view_permissions_advanced_options_blurb").'</div>';
	$xml_string .= '<select id="'.$basename.'_type" name="type">';

	# iterate through the array of types and print any that haven't been rendered yet
	foreach my $value (@view_permission_types)
	{
		if ($nameset_hash{$value})
		{
			$xml_string .= '<option value="'.$value.'">'.$session->phrase($namedset_name."_typename_".$value).'</option>';
		}
	}

#	$xml_string .='</select>
#		<input id="'.$basename.'_type_value" type="text" name="typevalue" onkeyup="doAutoComplete(\''.$basename.'\')" autocomplete="off"/>
#		<input type="button" value="Add" onclick="addPermissionType(\''.$basename.'\'); return false;" />
#		<div id="'.$basename.'_autocomplete_choices" class="autocomplete" style="display:none;"> </div>
#	</div>';

#add advanced options fill in here

#	$xml_string .= '</div>';
	return $div;
}

sub update_from_form
{
        my( $self, $processor ) = @_;
        my $session = $self->{session};
	my $basename = $self->{prefix}."_view_permissions";

        my $obj = $self->{dataobj};

        my $field = $self->{config}->{field};

	my $coarse_type = $session->param( $basename."_coarse_type" );
	my $advanced = $session->param( $basename."_advanced" );

	$obj->set_value( "view_permissions" , [ { type=>$coarse_type, value=>$coarse_type} ]);
}

