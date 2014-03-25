package EPrints::Plugin::Screen::EPrint::EdShareRemove;

@ISA = ( 'EPrints::Plugin::Screen::EPrint::Remove' );

use strict;

sub can_be_viewed
{
	my( $self ) = @_;

	# special code to block non-owners from deleting
	my $session = $self->{session};
	my $eprint = $self->{processor}->{eprint};
	my $current_user = $session->current_user;
	return 0 if ( defined $current_user and $current_user->value( "usertype" ) eq "user" and not $eprint->value( "userid" ) == $current_user->id );

	return 0 unless $self->could_obtain_eprint_lock;
	return $self->allow( "eprint/remove" );
}
