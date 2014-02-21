package EPrints::Plugin::Screen::EPrint::ExportZip;

@ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub can_be_viewed
{
        my( $self ) = @_;

	if($self->{processor}->{eprint}->get_value("type") eq "collection"){
		return 0;
	}
	return 1;
	
}


sub render
{
	my( $self ) = @_;
	
	my $session = $self->{session};

	my $url = $session->get_repository->get_conf("perl_url")."/export_zip?eprintid=".$self->{processor}->{eprint}->get_id;

	$session->redirect( $url );
	exit;
}


1;

