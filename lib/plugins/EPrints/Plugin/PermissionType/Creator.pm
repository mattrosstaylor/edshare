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

sub render_input
{
	my ( $self ) = @_;
	my $xml = $self->repository->xml;

	my $td = $xml->create_element( "td" );
	my $html = $xml->to_string( $self->html_phrase( "render_value") );
	my $basename = $self->{parent_component}->{basename};

	my $input = $xml->create_element( "input",
		type=>"button",
		value=>$self->phrase( "allow" ),
		id=>$basename."_creators_checkbox",
		onclick=>"permissionsAddPermittedFromString('Creators', 'Creators', '$html', '$basename');");

	$td->appendChild( $input );
	return $td;
}

sub render_value
{
	my ( $self, $value ) = @_;
	my $xml = $self->repository->xml;

	my $frag = $self->SUPER::render_value( $value );
	$frag->appendChild( $self->html_phrase( "render_value" )); 
	
	return $frag;
}

1;
