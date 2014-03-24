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

1;
