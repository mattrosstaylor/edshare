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

sub requires_list
{
	my ( $self ) = @_;
	return 1;
}

sub render
{
	my ( $self, $values ) = @_;
	my $xml = $self->repository->xml;
	my $basename = $self->{basename};
	my $js_var_name = $self->{js_var_name};

	my $frag = $xml->create_document_fragment;
	$frag->appendChild( $self->html_phrase( "prompt" ) );
	$frag->appendChild( $xml->create_element( "br" ) );

	$frag->appendChild( $self->html_phrase( "legend_name" ) );
	$frag->appendChild( $xml->create_element( "input",
		type=>"text",
		id=>$basename."_lookup_user_name",
		class=>"ep_form_text",
		onkeypress=> "return EPJS_block_enter( event );"
	));

	$frag->appendChild( $xml->create_element( "br" ) );
	$frag->appendChild( $self->html_phrase( "legend_email" ) );
	$frag->appendChild( $xml->create_element( "input",
		type=>"text",
		id=>$basename."_lookup_user_email",
		class=>"ep_form_text",
		onkeypress=> "return EPJS_block_enter( event );"
	));

	$frag->appendChild( $xml->create_element( "div",
		id=>$basename."_lookup_user_drop",
		class=>"ep_drop_target"
	));

	# mrt - I guess I put the javascript here?
	my $rel_path = $self->repository->get_conf( "rel_path" );

	$frag->appendChild( $self->repository->make_javascript(
		'ep_autocompleter_user_lookup('.
			'"' .$basename.'_lookup_user_name",'.
			'"' .$basename.'_lookup_user_drop",'.
			'"' .$rel_path.'/cgi/users/lookup/user",'.
			'"name",'.
			'"' .$js_var_name.'"'.
		');'
	));
	$frag->appendChild( $self->repository->make_javascript(
		'ep_autocompleter_user_lookup('.
			'"' .$basename.'_lookup_user_email",'.
			'"' .$basename.'_lookup_user_drop",'.
			'"' .$rel_path.'/cgi/users/lookup/user",'.
			'"email",'.
			'"' .$js_var_name.'"'.
		');'
	));

	$frag->appendChild( $self->_render_list_values( $values ) );
	return $frag;
}

sub _render_value
{
	my ( $self, $value ) = @_;

	my $user = EPrints::DataObj::User->new( $self->repository, $value );
	if (defined $user)
	{
		my $name = $user->value( "name" );
		return $name->{honourific}." ".$name->{given}." ".$name->{family}." (".$user->value("email").")";
	}
	else
	{
		return "Unknown user ". $value;
	}
}

1;
