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
	my $basename = $self->{parent_component}->{basename};

	my $td = $xml->create_element( "td" );
	$td->appendChild( $self->html_phrase( "legend_name" ) );
	$td->appendChild( $xml->create_element( "input",
		type=>"text",
		id=>$basename."_lookup_user_name",
		class=>"ep_form_text",
		onkeypress=> "return EPJS_block_enter( event );"
	));

	$td->appendChild( $xml->create_element( "br" ) );
	$td->appendChild( $self->html_phrase( "legend_email" ) );
	$td->appendChild( $xml->create_element( "input",
		type=>"text",
		id=>$basename."_lookup_user_email",
		class=>"ep_form_text",
		onkeypress=> "return EPJS_block_enter( event );"
	));

	$td->appendChild( $xml->create_element( "div",
		id=>$basename."_lookup_user_drop",
		class=>"ep_drop_target"
	));

	# mrt - I guess I put the javascript here?
	my $rel_path = $self->repository->get_conf( "rel_path" );

	$td->appendChild( $self->repository->make_javascript(
		'ep_autocompleter_user_lookup('.
			'"' .$basename.'_lookup_user_name",'.
			'"' .$basename.'_lookup_user_drop",'.
			'"' .$rel_path.'/cgi/users/lookup/user",'.
			'"name",'.
			'"' .$basename.'"'.
		');'
	));
	$td->appendChild( $self->repository->make_javascript(
		'ep_autocompleter_user_lookup('.
			'"' .$basename.'_lookup_user_email",'.
			'"' .$basename.'_lookup_user_drop",'.
			'"' .$rel_path.'/cgi/users/lookup/user",'.
			'"email",'.
			'"' .$basename.'"'.
		');'
	));

	return $td;
}

sub render_value
{
	my ( $self, $value ) = @_;
	my $xml = $self->repository->xml;

	my $frag = $self->SUPER::render_value( $value );
	my $user = EPrints::DataObj::User->new( $self->repository, $value );
	if (defined $user)
	{
		my $name = $user->value( "name" );
		$frag->appendChild( $xml->create_text_node( $name->{honourific}." ".$name->{given}." ".$name->{family}." (".$user->value("email").")" ) );
	}
	else
	{
		$frag->appendChild( $xml->create_text_node("Unknown user ". $value ) );
	}
	return $frag;
}

1;
