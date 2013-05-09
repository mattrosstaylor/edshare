package EPrints::Plugin::PremierePreviewScripts;

use strict;

our @ISA = qw/ EPrints::Plugin /;

package EPrints::Script::Compiled;

sub run_premierepreview_document_description
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
	#return [ $repo->xml->create_text_node($desc), "XHTML" ];
}

sub run_premierepreview_document_icon
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
