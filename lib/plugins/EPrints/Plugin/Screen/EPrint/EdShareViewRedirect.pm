package EPrints::Plugin::Screen::EPrint::EdShareViewRedirect;

@ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
	my( $class, %params ) = @_;
	my $self = $class->SUPER::new(%params);
	return $self;
}

# mrt - kekekekekekekekekekekekekekekekeke
sub can_be_viewed
{
        my( $self ) = @_;

	# redirect to either the summary page or public page depending on eprint status
	if ( $self->{processor}->{eprint}->value( "eprint_status" ) eq "inbox" )
	{
		$self->{processor}->{redirect} = $self->{session}->get_repository->get_conf( "userhome" )."?screen=EPrint::Summary&eprintid=".$self->{processor}->{eprintid};
	}
	else
	{
		$self->{processor}->{redirect} = $self->{session}->get_repository->get_conf( "base_url" )."/".$self->{processor}->{eprintid};
	}

	return 1;
}

1;
