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

	return $self;
}

sub render_input
{
	my ( $self ) = @_;
	my $xml = $self->repository->xml;

	my $td = $xml->create_element( "td" );
	my $input = $xml->create_element( "input",
		type=>"button",
		value=>$self->phrase( "allow" ),
		id=>$self->{parent_component}->{prefix}."_creators_checkbox"
	);

	$td->appendChild( $input );
	return $td;
}

1;
