package EPrints::Plugin::PremierePreviewScripts;

use strict;

our @ISA = qw/ EPrints::Plugin /;

package EPrints::Script::Compiled;


sub run_premiere_preview_license_icon
{
	my( $self, $state, $object ) = @_;
	my $repo = $state->{session}->get_repository;
	my $eprint = $object->[0];

	if( !defined $eprint || ref($eprint) ne "EPrints::DataObj::EPrint" )
	{
		$self->runtime_error( "Script '".caller(3) ."' can only be called on an EPrint not ". ref($eprint));
	}

	my $icon_url = $repo->xml->create_element("img", "class"=>"premiere_preview_license_icon", "src"=>"/style/images/license_icons/".$eprint->value("license").".png");

	return [ $icon_url, "XHTML" ];

}

sub run_premiere_preview_document_description
{
	my( $self, $state, $object ) = @_;
	my $repo = $state->{session}->get_repository;
	my $doc = $object->[0];

	if( !defined $doc || ref($doc) ne "EPrints::DataObj::Document" )
	{
		$self->runtime_error( "Script '".caller(3) ."' can only be called on a Document not ". ref($doc));
	}
	my $desc = $doc->value("description");

	$desc =~ s/^\s+//;
	$desc =~ s/\s+$//;

	if ( !$desc )
	{
		$desc = $doc->value("main");
	}
	
	return [ $desc, "STRING" ];
}

sub run_premiere_preview_document_icon
{
	my( $self, $state, $object ) = @_;
	my $repo = $state->{session}->get_repository;
	my $doc = $object->[0];

	if( !defined $doc || ref($doc) ne "EPrints::DataObj::Document" )
	{
		$self->runtime_error( "Script '".caller(3) ."' can only be called on a Document not ". ref($doc));
	}

	return [ $doc->icon_url, "STRING" ];
}


