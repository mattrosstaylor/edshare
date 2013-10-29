package EPrints::Plugin::Screen::EPrint::EdShareChangeOwner;

@ISA = ( 'EPrints::Plugin::Screen::EPrint::Staff::ChangeOwner' );

use strict;

sub can_be_viewed
{
	my ( $self ) = @_;
	return $self->allow_changeowner();
}

1;
