package EPrints::Plugin::PermissionType;

use EPrints;

@ISA = ( 'EPrints::Plugin');

$EPrints::Plugin::PermissionType::DISABLE = 1;

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = 'PermissionType Superclass';
	$self->{visible} = "all";

	$self->{parent_component} = $opts{parent_component};

	return $self;
}

sub render
{
	my ( $self ) = @_;
	my $xml = $self->repository->xml;

	my $row = $xml->create_element( "tr", valign=>"top" );
	$row->appendChild( $self->render_prompt() );
	$row->appendChild( $self->render_input() );

	return $row;
}

sub render_prompt
{
	my ( $self ) = @_;
	my $xml = $self->repository->xml;

	my $td = $xml->create_element( "td" );
	$td->appendChild( $self->html_phrase( "prompt" ) );
	return $td;
}

sub render_input
{
	my ( $self ) = @_;

	return $self->{repository}->xml->create_document_fragment;
}

1;
