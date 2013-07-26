package EPrints::Plugin::InputForm::Component::Field::ViewPermissions;

use EPrints;
use EPrints::Plugin::InputForm::Component::Field;

@ISA = ( 'EPrints::Plugin::InputForm::Component::Field');

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = 'View Permissions';
        $self->{visible} = "all";

	return $self;
}


sub render_content
{
#	my ( $field, $repo, $current_value, $dataset, $staff, $hidden_fields, $object, $basename ) = @_;
	my ( $self, $surround ) = @_;
	my $session = $self->{session};
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
	my @values = $session->get_types($namedset_name);
	my %nameset_hash = map { $_ => 1 } @values;

	my $xml_string = '<div>';

	my $first_value_type = @$value[0]->{type};
	my $show_advanced_options = (not ($first_value_type eq "public" or $first_value_type eq "private" or $first_value_type eq "restricted"));

	if( defined $nameset_hash{private} )
	{
		$xml_string .= '<input name="'.$basename.'_coarse_type" type="radio" value="private" onchange="hideAdvancedCheckbox(\''.$basename.'\')" ';
		if($first_value_type eq "private")
		{
			$xml_string .= 'checked="checked"';
		}
		$xml_string .= '/>'.$session->phrase($namedset_name."_typename_private");
		delete $nameset_hash{private};
	}
	
	if( defined $nameset_hash{public} )
	{
		$xml_string .= '<input name="'.$basename.'_coarse_type" type="radio" value="public" onchange="hideAdvancedCheckbox(\''.$basename.'\')" ';
		if($first_value_type eq "public")
		{
			$xml_string .= 'checked="checked"';
		}
		
		$xml_string .= '/>'.$session->phrase($namedset_name."_typename_public");
		delete $nameset_hash{public};
	}
	
	if( defined $nameset_hash{restricted} )
	{
		$xml_string .= '<input name="'.$basename.'_coarse_type" type="radio" value="restricted" onchange="showAdvancedCheckbox(\''.$basename.'\')" ';
		if( not ($first_value_type eq "public" or $first_value_type eq "private") )
		{
			$xml_string .= 'checked="checked"';
		}
		$xml_string .= '/>'.$session->phrase($namedset_name."_typename_restricted");
		delete $nameset_hash{restricted};
	}


	$xml_string .= '<span id="'.$basename.'_advanced" style="display:none;"><input type="checkbox" name="'.$basename.'_advanced_checkbox" id="'.$basename.'_advanced_checkbox" onchange="toggleAdvancedOptions(\''.$basename.'\')" ';
	if ($show_advanced_options)
	{
		$xml_string .= 'checked="checked"';
	}

	$xml_string .= '/> '.$session->phrase($namedset_name."_typename_show_advanced").'</span>';

	$xml_string .= '<div id="'.$basename.'_advanced_options" style="display:none;">
		<select id="'.$basename.'_type" name="type">';

	foreach my $value (keys %nameset_hash)
	{
		$xml_string .= '<option value="'.$value.'">'.$session->phrase($namedset_name."_typename_".$value).'</option>';
	}

	$xml_string .='</select>
		<input id="'.$basename.'_type_value" type="text" name="typevalue" onkeydown="doAutoComplete(\''.$basename.'\')" autocomplete="off"/>
		<input type="button" value="Add" onclick="addPermissionType(\''.$basename.'\'); return false;" />
		<div id="'.$basename.'_autocomplete_choices" class="autocomplete" style="display:none;"> </div>
	</div>';
=pod


		<div id="submit-values">';
	
	my $value_count = 0;
	foreach my $value (@{$value})
	{
		$value_count++;
		$xml_string .= "<div id='".$basename."_".$value_count."_container'>";
			# only display the values if advanced options
		if ($show_advanced_options) {
			$xml_string .= $value->{type}.": ".$value->{value};
			$xml_string .= "<a onclick='deletePermissionType(\"${basename}_${value_count}_container\"); return false' href='#'>X</a>";
		}
		$xml_string .= "<input type='hidden' value='".$value->{type}."' name='${basename}_${value_count}_type' />";
		$xml_string .= "<input type='hidden' value='".$value->{value}."' name='${basename}_${value_count}_value' />";
		$xml_string .= "</div>";
	}

	$xml_string .= '</div>
		<script type="text/javascript">
			document.'.$basename.'_count = 0;
			initPermsField("'.$basename.'");
		</script>
		<input type="hidden" name="'.$basename.'_spaces" id="'.$basename.'_spaces" value="'.$value_count.'"/>
</div>';
	my $temp_doc = $session->xml->parse_string($xml_string);
	foreach my $div ($temp_doc->getChildNodes())
	{
		return $div;
	}
=cut

	$xml_string .= '</div>';
	my $temp_doc = $session->xml->parse_string($xml_string);

	foreach my $div ($temp_doc->getChildNodes())
	{
		return $div;
	}
}

sub update_from_form
{
        my( $self, $processor ) = @_;
        my $session = $self->{session};
	my $basename = $self->{prefix}."_view_permissions";

        my $obj = $self->{dataobj};

        my $field = $self->{config}->{field};

	use Data::Dumper;

	my $coarse_type = $session->param( $basename."_coarse_type" );
	my $advanced = $session->param( $basename."_advanced" );

	$obj->set_value( "view_permissions" , [ { type=>$coarse_type, value=>$coarse_type} ]);
}

