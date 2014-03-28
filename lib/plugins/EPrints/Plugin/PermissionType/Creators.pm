package EPrints::Plugin::PermissionType::Creators;

use EPrints;
use EPrints::Plugin::PermissionType;

@ISA = ( 'EPrints::Plugin::PermissionType');

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = 'Creators PermissionType';
        $self->{visible} = "all";
	$self->{permission_type} = "Creators";

	return $self;
}

sub render
{
	my ( $self, $values ) = @_;
	my $xml = $self->repository->xml;

	my $frag = $xml->create_document_fragment;
	my $basename = $self->{basename};
	my $js_var_name = $self->{js_var_name};

	$frag->appendChild( $self->html_phrase( "prompt" ) );

	my $checkbox = $xml->create_element( "input", type=>"checkbox", name=>$basename."_Creators", value=>"Creators" );
	$frag->appendChild( $checkbox );

	if ( defined($values) and scalar(@$values) == 1 )
	{
		$checkbox->setAttribute( "checked", "checked" );
	}
	return $frag;
}

sub test
{
	my ( $self, $user, $eprint, $values ) = @_;

	my $user_email = $user->value( "email" );
	my $creator_emails = $eprint->value( "creators_id" );
	foreach my $creator_email ( @$creator_emails )
	{
		if ($creator_email eq $user_email) { return "ALLOW" }
	}

	return "DENY";
}

sub get_permitted_items_for_user
{
	my ( $self, $user ) = @_;
	my $session = $self->{session};

	my $ds = $session->get_dataset( 'eprint' );

	my $search = EPrints::Search->new(
		dataset => $ds,
		session => $session,
		satisfy_all => 1,
	);

	$search->add_field( $ds->get_field( $self->{fieldname}."_type" ), "Creators", "EX" );
	$search->add_field( $ds->get_field( "creators_id" ), $user->value( "email" ), "EX" );

	return $search->perform_search;
}

1;
