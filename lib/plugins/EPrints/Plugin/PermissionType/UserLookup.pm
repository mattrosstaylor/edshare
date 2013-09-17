package EPrints::Plugin::PermissionType::UserLookup;

use EPrints;
use EPrints::Plugin::PermissionType;

@ISA = ( 'EPrints::Plugin::PermissionType');

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = 'UserLookup PermissionType';
        $self->{visible} = "all";
	$self->{permission_type} = "UserLookup";

	return $self;
}

sub render_input
{
	my ( $self ) = @_;
	my $xml = $self->repository->xml;
	my $prefix = $self->{parent_component}->{prefix};

	my $td = $xml->create_element( "td" );
	$td->appendChild( $self->html_phrase( "legend_name" ) );
	$td->appendChild( $xml->create_element( "input",
		type=>"text",
		id=>$prefix."_lookup_user_name",
		class=>"ep_form_text",
		onkeypress=> "return EPJS_block_enter( event );"
	));
	$td->appendChild( $xml->create_element( "div",
		id=>$prefix."_lookup_user_name_drop",
		class=>"ep_drop_target"
	));

	$td->appendChild( $xml->create_element( "br" ) );
	$td->appendChild( $self->html_phrase( "legend_email" ) );
	$td->appendChild( $xml->create_element( "input",
		type=>"text",
		id=>$prefix."_lookup_user_email",
		class=>"ep_form_text",
		onkeypress=> "return EPJS_block_enter( event );"
	));

	# mrt - I guess I put the javascript here?
	my $rel_path = $self->repository->get_conf( "rel_path" );
	my $js_var_name = "fuck knows";

	$td->appendChild( $self->repository->make_javascript(
		'ep_autocompleter_selected_users('.
			'"' .$prefix.'_lookup_user_name",'.
			'"' .$prefix.'_lookup_user_name_drop",'.
			'"' .$rel_path.'/cgi/users/lookup/user",'.
			'"name",'.
			'"only_fuck_knows",'.
			'"seriously, what is this???"'.
		');'
	));

	return $td;
}

sub render_value
{
	my ( $self, $value ) = @_;
	my $xml = $self->repository->xml;

	my $frag = $self->SUPER::render_value( $value );
	$frag->appendChild( $xml->create_text_node( "User " ) ); 
	$frag->appendChild( $xml->create_text_node( "(".$value.")" ) );
	
	return $frag;
}

1;
